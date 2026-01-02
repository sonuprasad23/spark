/**
 * SPARK Matching Service - Cloud Functions
 * Handles compatibility scoring and match generation
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();
const USERS_COLLECTION = 'users';
const PREFERENCES_COLLECTION = 'preferences';
const MATCHES_COLLECTION = 'matches';
const QUESTIONNAIRE_COLLECTION = 'questionnaires';

interface MatchRecord {
    id: string;
    userId: string;
    matchedUserId: string;
    compatibilityScore: number;
    weekNumber: number;
    year: number;
    status: 'pending' | 'viewed' | 'connected' | 'passed' | 'expired';
    userAction?: 'connect' | 'pass';
    matchAction?: 'connect' | 'pass';
    isMutualMatch: boolean;
    createdAt: admin.firestore.Timestamp;
    expiresAt: admin.firestore.Timestamp;
    decidedAt?: admin.firestore.Timestamp;
}

/**
 * Calculate compatibility score between two users
 */
export const calculateCompatibility = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    }

    const { userId1, userId2 } = data;

    try {
        // Fetch both users
        const [user1Doc, user2Doc] = await Promise.all([
            db.collection(USERS_COLLECTION).doc(userId1).get(),
            db.collection(USERS_COLLECTION).doc(userId2).get(),
        ]);

        if (!user1Doc.exists || !user2Doc.exists) {
            throw new functions.https.HttpsError('not-found', 'User not found');
        }

        const user1 = user1Doc.data();
        const user2 = user2Doc.data();

        // Fetch questionnaire answers
        const [q1Doc, q2Doc] = await Promise.all([
            db.collection(QUESTIONNAIRE_COLLECTION).doc(userId1).get(),
            db.collection(QUESTIONNAIRE_COLLECTION).doc(userId2).get(),
        ]);

        const q1 = q1Doc.data()?.answers || [];
        const q2 = q2Doc.data()?.answers || [];

        const score = computeCompatibilityScore(user1, user2, q1, q2);

        return { compatibilityScore: score };
    } catch (error) {
        console.error('Error calculating compatibility:', error);
        throw new functions.https.HttpsError('internal', 'Failed to calculate compatibility');
    }
});

/**
 * Find potential matches for a user
 */
export const findPotentialMatches = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    }

    const userId = context.auth.uid;

    try {
        // Get user and preferences
        const [userDoc, prefsDoc] = await Promise.all([
            db.collection(USERS_COLLECTION).doc(userId).get(),
            db.collection(PREFERENCES_COLLECTION).doc(userId).get(),
        ]);

        if (!userDoc.exists) {
            throw new functions.https.HttpsError('not-found', 'User not found');
        }

        const user = userDoc.data();
        const prefs = prefsDoc.data();

        if (!prefs) {
            throw new functions.https.HttpsError('not-found', 'Preferences not found');
        }

        // Build query for potential matches
        let query = db.collection(USERS_COLLECTION)
            .where('isActive', '==', true)
            .where('gender', '==', prefs.lookingFor === 'both' ? undefined : prefs.lookingFor)
            .where('age', '>=', prefs.ageRange.min)
            .where('age', '<=', prefs.ageRange.max);

        // Filter by city if specified
        if (prefs.cities && prefs.cities.length > 0) {
            query = query.where('city', 'in', prefs.cities);
        }

        const potentialMatches = await query.limit(100).get();

        // Filter out already matched users this week
        const currentWeek = getWeekNumber();
        const existingMatchesSnap = await db.collection(MATCHES_COLLECTION)
            .where('userId', '==', userId)
            .where('weekNumber', '==', currentWeek)
            .get();

        const matchedUserIds = new Set(existingMatchesSnap.docs.map(d => d.data().matchedUserId));
        matchedUserIds.add(userId); // Don't match with self

        // Calculate compatibility and rank
        const scoredMatches: Array<{ userId: string; score: number }> = [];

        for (const doc of potentialMatches.docs) {
            if (matchedUserIds.has(doc.id)) continue;

            const matchData = doc.data();

            // Quick compatibility check
            const score = computeQuickCompatibility(user, matchData);
            if (score >= 60) { // Minimum threshold
                scoredMatches.push({ userId: doc.id, score });
            }
        }

        // Sort by score and return top matches
        scoredMatches.sort((a, b) => b.score - a.score);

        const matchLimit = user?.isPremium && user?.premiumTier === 'pro' ? 10 :
            user?.isPremium ? 7 : 5;

        return {
            matches: scoredMatches.slice(0, matchLimit),
            weekNumber: currentWeek,
        };
    } catch (error) {
        console.error('Error finding matches:', error);
        throw new functions.https.HttpsError('internal', 'Failed to find matches');
    }
});

/**
 * Record user action on a match (connect/pass)
 */
export const recordMatchAction = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    }

    const userId = context.auth.uid;
    const { matchId, action } = data;

    if (!matchId || !['connect', 'pass'].includes(action)) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid match ID or action');
    }

    try {
        const matchRef = db.collection(MATCHES_COLLECTION).doc(matchId);
        const matchDoc = await matchRef.get();

        if (!matchDoc.exists) {
            throw new functions.https.HttpsError('not-found', 'Match not found');
        }

        const matchData = matchDoc.data() as MatchRecord;

        // Determine which user is acting
        const isUser = matchData.userId === userId;
        const isMatch = matchData.matchedUserId === userId;

        if (!isUser && !isMatch) {
            throw new functions.https.HttpsError('permission-denied', 'Not authorized');
        }

        const updateField = isUser ? 'userAction' : 'matchAction';

        await matchRef.update({
            [updateField]: action,
            status: action === 'connect' ? 'connected' : 'passed',
            decidedAt: admin.firestore.Timestamp.now(),
        });

        // Check for mutual match
        const updatedMatch = (await matchRef.get()).data() as MatchRecord;
        if (updatedMatch.userAction === 'connect' && updatedMatch.matchAction === 'connect') {
            await matchRef.update({ isMutualMatch: true });

            // Create chat room for mutual matches
            await createChatRoom(matchData.userId, matchData.matchedUserId, matchId);

            return { success: true, mutualMatch: true };
        }

        return { success: true, mutualMatch: false };
    } catch (error) {
        console.error('Error recording match action:', error);
        throw new functions.https.HttpsError('internal', 'Failed to record action');
    }
});

/**
 * Get user's matches for current week
 */
export const getWeeklyMatches = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    }

    const userId = context.auth.uid;
    const weekNumber = getWeekNumber();

    try {
        const matchesSnap = await db.collection(MATCHES_COLLECTION)
            .where('userId', '==', userId)
            .where('weekNumber', '==', weekNumber)
            .orderBy('compatibilityScore', 'desc')
            .get();

        const matches = await Promise.all(matchesSnap.docs.map(async (doc) => {
            const matchData = doc.data();
            const matchedUserDoc = await db.collection(USERS_COLLECTION)
                .doc(matchData.matchedUserId).get();

            const matchedUser = matchedUserDoc.data();

            return {
                id: doc.id,
                ...matchData,
                matchedUser: {
                    id: matchedUser?.id,
                    name: matchedUser?.name,
                    age: matchedUser?.age,
                    city: matchedUser?.city,
                    photos: matchedUser?.photos,
                    bio: matchedUser?.bio,
                    isVerified: matchedUser?.isVerified,
                },
            };
        }));

        return { matches, weekNumber };
    } catch (error) {
        console.error('Error getting matches:', error);
        throw new functions.https.HttpsError('internal', 'Failed to get matches');
    }
});

// Helper functions

function computeCompatibilityScore(
    user1: any,
    user2: any,
    q1: number[],
    q2: number[]
): number {
    let score = 0;
    let maxScore = 0;

    // Interest overlap (30%)
    const interests1 = new Set(user1.interests || []);
    const interests2 = new Set(user2.interests || []);
    const commonInterests = [...interests1].filter(i => interests2.has(i)).length;
    const totalInterests = Math.max(interests1.size, interests2.size, 1);
    score += (commonInterests / totalInterests) * 30;
    maxScore += 30;

    // Questionnaire similarity (50%)
    if (q1.length > 0 && q2.length > 0) {
        const minLen = Math.min(q1.length, q2.length);
        let similarity = 0;
        for (let i = 0; i < minLen; i++) {
            // Each answer is 1-5, calculate closeness
            const diff = Math.abs(q1[i] - q2[i]);
            similarity += (4 - diff) / 4; // 0 to 1 for each question
        }
        score += (similarity / minLen) * 50;
        maxScore += 50;
    }

    // Location proximity (10%)
    if (user1.city === user2.city) {
        score += 10;
    }
    maxScore += 10;

    // Profile completeness bonus (10%)
    const avgCompleteness = ((user1.profileCompleteness || 0) + (user2.profileCompleteness || 0)) / 2;
    score += (avgCompleteness / 100) * 10;
    maxScore += 10;

    return Math.round((score / maxScore) * 100);
}

function computeQuickCompatibility(user1: any, user2: any): number {
    // Simplified compatibility for initial filtering
    let score = 50; // Base score

    // Interest overlap
    const interests1 = new Set(user1.interests || []);
    const interests2 = new Set(user2.interests || []);
    const commonInterests = [...interests1].filter(i => interests2.has(i)).length;
    score += commonInterests * 5;

    // Same city bonus
    if (user1.city === user2.city) score += 10;

    // Both verified bonus
    if (user1.isVerified && user2.isVerified) score += 10;

    return Math.min(score, 100);
}

function getWeekNumber(): number {
    const now = new Date();
    const start = new Date(now.getFullYear(), 0, 1);
    const diff = now.getTime() - start.getTime();
    const oneWeek = 604800000; // milliseconds in a week
    return Math.ceil(diff / oneWeek);
}

async function createChatRoom(userId1: string, userId2: string, matchId: string): Promise<void> {
    const now = admin.firestore.Timestamp.now();
    const expiresAt = admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7 days from now
    );

    await db.collection('rooms').add({
        matchId,
        participants: [userId1, userId2],
        dayNumber: 1,
        startedAt: now,
        expiresAt,
        lastMessageAt: now,
        messageCount: 0,
        status: 'active',
        createdAt: now,
    });
}
