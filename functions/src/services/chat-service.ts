/**
 * SPARK Chat Service - Cloud Functions
 * Handles chat rooms, messaging, and notifications
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();
const ROOMS_COLLECTION = 'rooms';
const MESSAGES_COLLECTION = 'messages';
const USERS_COLLECTION = 'users';

interface ChatRoom {
    id: string;
    matchId: string;
    participants: string[];
    dayNumber: number;
    startedAt: admin.firestore.Timestamp;
    expiresAt: admin.firestore.Timestamp;
    lastMessageAt: admin.firestore.Timestamp;
    messageCount: number;
    status: 'active' | 'expired' | 'connected' | 'passed';
    decisions: {
        [userId: string]: 'connect' | 'pass' | 'extend';
    };
    extensionsUsed: number;
    createdAt: admin.firestore.Timestamp;
}

interface Message {
    id: string;
    roomId: string;
    senderId: string;
    text: string;
    type: 'text' | 'voice' | 'image';
    mediaUrl?: string;
    duration?: number; // For voice notes
    status: 'sent' | 'delivered' | 'read';
    createdAt: admin.firestore.Timestamp;
}

/**
 * Send a message in a chat room
 */
export const sendMessage = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    }

    const userId = context.auth.uid;
    const { roomId, text, type = 'text', mediaUrl, duration } = data;

    if (!roomId || (!text && !mediaUrl)) {
        throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
    }

    try {
        // Verify user is participant
        const roomRef = db.collection(ROOMS_COLLECTION).doc(roomId);
        const roomDoc = await roomRef.get();

        if (!roomDoc.exists) {
            throw new functions.https.HttpsError('not-found', 'Room not found');
        }

        const roomData = roomDoc.data() as ChatRoom;

        if (!roomData.participants.includes(userId)) {
            throw new functions.https.HttpsError('permission-denied', 'Not a participant');
        }

        if (roomData.status !== 'active' && roomData.status !== 'connected') {
            throw new functions.https.HttpsError('failed-precondition', 'Room is not active');
        }

        // Check feature restrictions based on day
        if (type === 'voice' && roomData.dayNumber < 3) {
            throw new functions.https.HttpsError('failed-precondition', 'Voice notes unlock on Day 3');
        }

        if (type === 'image' && roomData.dayNumber < 5) {
            throw new functions.https.HttpsError('failed-precondition', 'Images unlock on Day 5');
        }

        // Create message
        const now = admin.firestore.Timestamp.now();
        const messageRef = db.collection(MESSAGES_COLLECTION).doc();

        const message: Message = {
            id: messageRef.id,
            roomId,
            senderId: userId,
            text: text || '',
            type,
            mediaUrl,
            duration,
            status: 'sent',
            createdAt: now,
        };

        // Update room stats
        const batch = db.batch();
        batch.set(messageRef, message);
        batch.update(roomRef, {
            lastMessageAt: now,
            messageCount: admin.firestore.FieldValue.increment(1),
        });
        await batch.commit();

        // Send push notification to other participant
        const otherUserId = roomData.participants.find(p => p !== userId);
        if (otherUserId) {
            await sendPushNotification(otherUserId, userId, text || 'Sent a message');
        }

        return { success: true, messageId: messageRef.id };
    } catch (error) {
        console.error('Error sending message:', error);
        throw new functions.https.HttpsError('internal', 'Failed to send message');
    }
});

/**
 * Get messages for a room
 */
export const getMessages = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    }

    const userId = context.auth.uid;
    const { roomId, limit = 50, before } = data;

    try {
        // Verify user is participant
        const roomDoc = await db.collection(ROOMS_COLLECTION).doc(roomId).get();
        if (!roomDoc.exists) {
            throw new functions.https.HttpsError('not-found', 'Room not found');
        }

        const roomData = roomDoc.data() as ChatRoom;
        if (!roomData.participants.includes(userId)) {
            throw new functions.https.HttpsError('permission-denied', 'Not a participant');
        }

        // Query messages
        let query = db.collection(MESSAGES_COLLECTION)
            .where('roomId', '==', roomId)
            .orderBy('createdAt', 'desc')
            .limit(limit);

        if (before) {
            query = query.startAfter(admin.firestore.Timestamp.fromMillis(before));
        }

        const messagesSnap = await query.get();
        const messages = messagesSnap.docs.map(doc => doc.data()).reverse();

        return { messages };
    } catch (error) {
        console.error('Error getting messages:', error);
        throw new functions.https.HttpsError('internal', 'Failed to get messages');
    }
});

/**
 * Mark messages as read
 */
export const markMessagesRead = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    }

    const userId = context.auth.uid;
    const { roomId } = data;

    try {
        // Get unread messages from other user
        const messagesSnap = await db.collection(MESSAGES_COLLECTION)
            .where('roomId', '==', roomId)
            .where('status', 'in', ['sent', 'delivered'])
            .get();

        const batch = db.batch();
        messagesSnap.docs.forEach(doc => {
            const msg = doc.data();
            if (msg.senderId !== userId) {
                batch.update(doc.ref, { status: 'read' });
            }
        });

        await batch.commit();

        return { success: true, markedCount: messagesSnap.size };
    } catch (error) {
        console.error('Error marking messages read:', error);
        throw new functions.https.HttpsError('internal', 'Failed to mark read');
    }
});

/**
 * Make Day 7 decision
 */
export const makeRoomDecision = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    }

    const userId = context.auth.uid;
    const { roomId, decision } = data;

    if (!roomId || !['connect', 'pass', 'extend'].includes(decision)) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid room ID or decision');
    }

    try {
        const roomRef = db.collection(ROOMS_COLLECTION).doc(roomId);
        const roomDoc = await roomRef.get();

        if (!roomDoc.exists) {
            throw new functions.https.HttpsError('not-found', 'Room not found');
        }

        const roomData = roomDoc.data() as ChatRoom;

        if (!roomData.participants.includes(userId)) {
            throw new functions.https.HttpsError('permission-denied', 'Not a participant');
        }

        // Handle extend request
        if (decision === 'extend') {
            // Check if user is premium
            const userDoc = await db.collection(USERS_COLLECTION).doc(userId).get();
            const userData = userDoc.data();

            if (!userData?.isPremium) {
                throw new functions.https.HttpsError('failed-precondition', 'Premium required to extend');
            }

            if (roomData.extensionsUsed >= 1) {
                throw new functions.https.HttpsError('failed-precondition', 'Already extended once');
            }

            // Extend by 3 days
            const newExpiry = new Date(roomData.expiresAt.toDate().getTime() + 3 * 24 * 60 * 60 * 1000);
            await roomRef.update({
                expiresAt: admin.firestore.Timestamp.fromDate(newExpiry),
                dayNumber: Math.max(1, roomData.dayNumber - 3),
                extensionsUsed: roomData.extensionsUsed + 1,
            });

            return { success: true, extended: true };
        }

        // Record decision
        const decisions = roomData.decisions || {};
        decisions[userId] = decision;

        await roomRef.update({
            decisions,
            [`decisions.${userId}`]: decision,
        });

        // Check if both users decided
        const otherUserId = roomData.participants.find(p => p !== userId);
        const otherDecision = decisions[otherUserId!];

        if (otherDecision) {
            // Both decided
            if (decisions[userId] === 'connect' && otherDecision === 'connect') {
                // Mutual connection - room becomes permanent
                await roomRef.update({ status: 'connected' });

                // Notify both users
                await sendPushNotification(userId, otherUserId!, 'You matched! Start chatting 💕');
                await sendPushNotification(otherUserId!, userId, 'You matched! Start chatting 💕');

                return { success: true, mutualMatch: true };
            } else {
                // At least one passed
                await roomRef.update({ status: 'passed' });
                return { success: true, mutualMatch: false };
            }
        }

        return { success: true, awaitingOther: true };
    } catch (error) {
        console.error('Error making decision:', error);
        throw new functions.https.HttpsError('internal', 'Failed to make decision');
    }
});

/**
 * Get user's active rooms
 */
export const getActiveRooms = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    }

    const userId = context.auth.uid;

    try {
        const roomsSnap = await db.collection(ROOMS_COLLECTION)
            .where('participants', 'array-contains', userId)
            .where('status', 'in', ['active', 'connected'])
            .orderBy('lastMessageAt', 'desc')
            .get();

        const rooms = await Promise.all(roomsSnap.docs.map(async (doc) => {
            const roomData = doc.data() as ChatRoom;
            const otherUserId = roomData.participants.find(p => p !== userId);

            // Get other user's info
            const otherUserDoc = await db.collection(USERS_COLLECTION).doc(otherUserId!).get();
            const otherUser = otherUserDoc.data();

            // Get last message
            const lastMsgSnap = await db.collection(MESSAGES_COLLECTION)
                .where('roomId', '==', doc.id)
                .orderBy('createdAt', 'desc')
                .limit(1)
                .get();

            const lastMessage = lastMsgSnap.docs[0]?.data();

            // Count unread
            const unreadSnap = await db.collection(MESSAGES_COLLECTION)
                .where('roomId', '==', doc.id)
                .where('senderId', '!=', userId)
                .where('status', 'in', ['sent', 'delivered'])
                .get();

            return {
                id: doc.id,
                ...roomData,
                otherUser: {
                    id: otherUser?.id,
                    name: otherUser?.name,
                    photos: otherUser?.photos,
                },
                lastMessage: lastMessage?.text || null,
                lastMessageTime: lastMessage?.createdAt || roomData.startedAt,
                unreadCount: unreadSnap.size,
            };
        }));

        return { rooms };
    } catch (error) {
        console.error('Error getting rooms:', error);
        throw new functions.https.HttpsError('internal', 'Failed to get rooms');
    }
});

// Push notification helper
async function sendPushNotification(
    toUserId: string,
    fromUserId: string,
    body: string
): Promise<void> {
    try {
        // Get recipient's FCM token
        const userDoc = await db.collection(USERS_COLLECTION).doc(toUserId).get();
        const fcmToken = userDoc.data()?.fcmToken;

        if (!fcmToken) return;

        // Get sender's name
        const senderDoc = await db.collection(USERS_COLLECTION).doc(fromUserId).get();
        const senderName = senderDoc.data()?.name || 'Someone';

        await admin.messaging().send({
            token: fcmToken,
            notification: {
                title: senderName,
                body,
            },
            data: {
                type: 'chat',
                senderId: fromUserId,
            },
            android: {
                priority: 'high',
                notification: {
                    channelId: 'chat_messages',
                },
            },
            apns: {
                payload: {
                    aps: {
                        badge: 1,
                        sound: 'default',
                    },
                },
            },
        });
    } catch (error) {
        console.error('Error sending push notification:', error);
        // Don't throw - push notification failure shouldn't fail the main operation
    }
}
