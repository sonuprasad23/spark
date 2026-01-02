/**
 * Room Expiry Handler - Scheduled Cloud Function
 * Runs daily to check and update expired chat rooms
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();
const ROOMS_COLLECTION = 'rooms';
const USERS_COLLECTION = 'users';

/**
 * Scheduled function to handle room expirations
 * Runs every day at midnight IST
 */
export const processRoomExpirations = functions.pubsub
    .schedule('0 18 * * *') // 6:00 PM UTC = 11:30 PM IST
    .timeZone('Asia/Kolkata')
    .onRun(async (context) => {
        console.log('Processing room expirations...');

        try {
            const now = admin.firestore.Timestamp.now();

            // Find expired active rooms
            const expiredRoomsSnap = await db.collection(ROOMS_COLLECTION)
                .where('status', '==', 'active')
                .where('expiresAt', '<=', now)
                .get();

            console.log(`Found ${expiredRoomsSnap.size} expired rooms`);

            let expiredCount = 0;
            let decisionPendingCount = 0;

            for (const doc of expiredRoomsSnap.docs) {
                const roomData = doc.data();
                const decisions = roomData.decisions || {};
                const participants = roomData.participants || [];

                // Check if both made decisions
                const user1Decision = decisions[participants[0]];
                const user2Decision = decisions[participants[1]];

                if (user1Decision && user2Decision) {
                    // Both decided - check for mutual match
                    if (user1Decision === 'connect' && user2Decision === 'connect') {
                        await doc.ref.update({ status: 'connected' });

                        // Send celebration notification
                        for (const userId of participants) {
                            await sendExpiryNotification(userId, 'mutual_match');
                        }
                    } else {
                        await doc.ref.update({ status: 'passed' });
                    }
                } else {
                    // At least one didn't decide - auto-expire
                    await doc.ref.update({ status: 'expired' });
                    decisionPendingCount++;

                    // Notify participants about expiration
                    for (const userId of participants) {
                        await sendExpiryNotification(userId, 'expired');
                    }
                }

                expiredCount++;
            }

            console.log(`Processed ${expiredCount} rooms (${decisionPendingCount} auto-expired)`);
            return null;
        } catch (error) {
            console.error('Room expiration processing failed:', error);
            throw error;
        }
    });

/**
 * Update day number for active rooms
 * Runs daily to increment day counter
 */
export const updateRoomDays = functions.pubsub
    .schedule('0 18 * * *') // Same time as expiry check
    .timeZone('Asia/Kolkata')
    .onRun(async (context) => {
        console.log('Updating room day numbers...');

        try {
            const activeRoomsSnap = await db.collection(ROOMS_COLLECTION)
                .where('status', '==', 'active')
                .get();

            const now = new Date();
            let updatedCount = 0;

            for (const doc of activeRoomsSnap.docs) {
                const roomData = doc.data();
                const startedAt = roomData.startedAt.toDate();

                // Calculate actual day number
                const daysSinceStart = Math.floor(
                    (now.getTime() - startedAt.getTime()) / (24 * 60 * 60 * 1000)
                ) + 1;

                const newDayNumber = Math.min(daysSinceStart, 7);

                if (newDayNumber !== roomData.dayNumber) {
                    await doc.ref.update({ dayNumber: newDayNumber });
                    updatedCount++;

                    // Send decision day reminder on Day 6 and 7
                    if (newDayNumber >= 6) {
                        for (const userId of roomData.participants) {
                            await sendDecisionReminder(userId, newDayNumber, roomData);
                        }
                    }
                }
            }

            console.log(`Updated ${updatedCount} room day numbers`);
            return null;
        } catch (error) {
            console.error('Room day update failed:', error);
            throw error;
        }
    });

/**
 * Clean up old expired rooms
 * Runs weekly to archive old data
 */
export const cleanupOldRooms = functions.pubsub
    .schedule('0 0 * * 0') // Midnight every Sunday
    .timeZone('Asia/Kolkata')
    .onRun(async (context) => {
        console.log('Cleaning up old rooms...');

        try {
            const thirtyDaysAgo = admin.firestore.Timestamp.fromDate(
                new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)
            );

            // Find rooms older than 30 days that are not connected
            const oldRoomsSnap = await db.collection(ROOMS_COLLECTION)
                .where('status', 'in', ['expired', 'passed'])
                .where('expiresAt', '<=', thirtyDaysAgo)
                .limit(500) // Process in batches
                .get();

            console.log(`Found ${oldRoomsSnap.size} old rooms to archive`);

            const batch = db.batch();
            let count = 0;

            for (const doc of oldRoomsSnap.docs) {
                // Move to archive collection
                batch.set(db.collection('rooms_archive').doc(doc.id), doc.data());
                batch.delete(doc.ref);
                count++;

                if (count >= 400) {
                    await batch.commit();
                    console.log(`Archived ${count} rooms`);
                }
            }

            if (count > 0) {
                await batch.commit();
            }

            console.log(`Total archived: ${oldRoomsSnap.size} rooms`);
            return null;
        } catch (error) {
            console.error('Room cleanup failed:', error);
            throw error;
        }
    });

// Helper functions

async function sendExpiryNotification(userId: string, type: 'expired' | 'mutual_match'): Promise<void> {
    try {
        const userDoc = await db.collection(USERS_COLLECTION).doc(userId).get();
        const fcmToken = userDoc.data()?.fcmToken;

        if (!fcmToken) return;

        let title: string;
        let body: string;

        if (type === 'mutual_match') {
            title = '🎉 It\'s a match!';
            body = 'You both chose to connect! Start your journey together.';
        } else {
            title = '⏰ Connection room expired';
            body = 'Your 7-day connection room has ended. New matches await!';
        }

        await admin.messaging().send({
            token: fcmToken,
            notification: { title, body },
            data: { type },
            android: {
                priority: 'high',
                notification: { channelId: 'rooms' },
            },
        });
    } catch (error) {
        console.error('Error sending expiry notification:', error);
    }
}

async function sendDecisionReminder(userId: string, dayNumber: number, roomData: any): Promise<void> {
    try {
        const userDoc = await db.collection(USERS_COLLECTION).doc(userId).get();
        const fcmToken = userDoc.data()?.fcmToken;

        if (!fcmToken) return;

        const otherUserId = roomData.participants.find((p: string) => p !== userId);
        const otherUserDoc = await db.collection(USERS_COLLECTION).doc(otherUserId).get();
        const otherName = otherUserDoc.data()?.name || 'your match';

        const title = dayNumber === 7
            ? '⏰ Decision day!'
            : '📅 1 day left to decide';

        const body = dayNumber === 7
            ? `Time to decide about ${otherName}. Connect or pass?`
            : `Your room with ${otherName} expires tomorrow. Make the most of today!`;

        await admin.messaging().send({
            token: fcmToken,
            notification: { title, body },
            data: {
                type: 'decision_reminder',
                roomId: roomData.id,
            },
            android: {
                priority: 'high',
                notification: { channelId: 'reminders' },
            },
        });
    } catch (error) {
        console.error('Error sending decision reminder:', error);
    }
}
