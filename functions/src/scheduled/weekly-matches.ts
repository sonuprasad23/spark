/**
 * Weekly Match Generation - Scheduled Cloud Function
 * Runs every Sunday at 10 AM IST to generate new matches
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();
const USERS_COLLECTION = 'users';
const PREFERENCES_COLLECTION = 'preferences';
const MATCHES_COLLECTION = 'matches';
const QUESTIONNAIRE_COLLECTION = 'questionnaires';

/**
 * Scheduled function to generate weekly matches for all users
 * Runs every Sunday at 10:00 AM IST (4:30 AM UTC)
 */
export const generateWeeklyMatches = functions.pubsub
    .schedule('30 4 * * 0') // 4:30 AM UTC every Sunday
    .timeZone('Asia/Kolkata')
    .onRun(async (context) => {
        console.log('Starting weekly match generation...');

        try {
            // Get all active users
            const usersSnap = await db.collection(USERS_COLLECTION)
                .where('isActive', '==', true)
                .where('profileCompleteness', '>=', 50) // Minimum profile requirement
                .get();

            console.log(`Processing ${usersSnap.size} active users`);

            const weekNumber = getWeekNumber();
            const year = new Date().getFullYear();
            const now = admin.firestore.Timestamp.now();
            const expiresAt = admin.firestore.Timestamp.fromDate(
                new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
            );

            let totalMatches = 0;
            let processedUsers = 0;

            for (const userDoc of usersSnap.docs) {
                try {
                    const userId = userDoc.id;
                    const userData = userDoc.data();

                    // Get user preferences
                    const prefsDoc = await db.collection(PREFERENCES_COLLECTION).doc(userId).get();
                    const prefs = prefsDoc.data();

                    if (!prefs) {
                        console.log(`Skipping user ${userId}: No preferences`);
                        continue;
                    }

                    // Determine match limit based on premium status
                    const matchLimit = userData.isPremium && userData.premiumTier === 'pro' ? 10 :
                        userData.isPremium ? 7 : 5;

                    // Find potential matches
                    const potentialMatches = await findMatchesForUser(userId, userData, prefs, weekNumber);

                    // Calculate compatibility and create matches
                    const topMatches = potentialMatches
                        .slice(0, matchLimit);

                    // Create match records
                    const batch = db.batch();
                    for (const match of topMatches) {
                        const matchRef = db.collection(MATCHES_COLLECTION).doc();
                        batch.set(matchRef, {
                            id: matchRef.id,
                            userId,
                            matchedUserId: match.userId,
                            compatibilityScore: match.score,
                            weekNumber,
                            year,
                            status: 'pending',
                            isMutualMatch: false,
                            createdAt: now,
                            expiresAt,
                        });
                        totalMatches++;
                    }

                    await batch.commit();
                    processedUsers++;

                    // Send notification about new matches
                    if (topMatches.length > 0 && userData.fcmToken) {
                        await sendNewMatchesNotification(userData.fcmToken, topMatches.length);
                    }

                } catch (error) {
                    console.error(`Error processing user ${userDoc.id}:`, error);
                    // Continue with other users
                }
            }

            console.log(`Weekly match generation complete: ${totalMatches} matches for ${processedUsers} users`);
            return null;
        } catch (error) {
            console.error('Weekly match generation failed:', error);
            throw error;
        }
    });

/**
 * Find potential matches for a user
 */
async function findMatchesForUser(
    userId: string,
    userData: any,
    prefs: any,
    weekNumber: number
): Promise<Array<{ userId: string; score: number }>> {
    // Get users that match preferences
    let query = db.collection(USERS_COLLECTION)
        .where('isActive', '==', true)
        .where('profileCompleteness', '>=', 50);

    // Gender preference
    if (prefs.lookingFor !== 'both') {
        query = query.where('gender', '==', prefs.lookingFor);
    }

    // Age range
    query = query
        .where('age', '>=', prefs.ageRange?.min || 18)
        .where('age', '<=', prefs.ageRange?.max || 50);

    const potentialSnap = await query.limit(200).get();

    // Get existing matches this week to exclude
    const existingMatchesSnap = await db.collection(MATCHES_COLLECTION)
        .where('userId', '==', userId)
        .where('weekNumber', '==', weekNumber)
        .get();

    const excludeIds = new Set<string>([userId]);
    existingMatchesSnap.docs.forEach(d => excludeIds.add(d.data().matchedUserId));

    // Get questionnaire answers
    const userQDoc = await db.collection(QUESTIONNAIRE_COLLECTION).doc(userId).get();
    const userAnswers = userQDoc.data()?.answers || [];

    // Score potential matches
    const scoredMatches: Array<{ userId: string; score: number }> = [];

    for (const doc of potentialSnap.docs) {
        if (excludeIds.has(doc.id)) continue;

        const matchData = doc.data();

        // Check if this user's preferences match with original user
        const matchPrefsDoc = await db.collection(PREFERENCES_COLLECTION).doc(doc.id).get();
        const matchPrefs = matchPrefsDoc.data();

        // Check gender compatibility
        if (matchPrefs?.lookingFor !== 'both' && matchPrefs?.lookingFor !== userData.gender) {
            continue;
        }

        // Check age compatibility
        if (matchPrefs?.ageRange) {
            if (userData.age < matchPrefs.ageRange.min || userData.age > matchPrefs.ageRange.max) {
                continue;
            }
        }

        // Calculate compatibility score
        const matchQDoc = await db.collection(QUESTIONNAIRE_COLLECTION).doc(doc.id).get();
        const matchAnswers = matchQDoc.data()?.answers || [];

        const score = calculateCompatibility(userData, matchData, userAnswers, matchAnswers);

        if (score >= 60) { // Minimum threshold
            scoredMatches.push({ userId: doc.id, score });
        }
    }

    // Sort by score
    scoredMatches.sort((a, b) => b.score - a.score);

    return scoredMatches;
}

/**
 * Calculate compatibility score
 */
function calculateCompatibility(
    user1: any,
    user2: any,
    q1: number[],
    q2: number[]
): number {
    let score = 0;

    // Interest overlap (30 points)
    const interests1 = new Set(user1.interests || []);
    const interests2 = new Set(user2.interests || []);
    const commonInterests = [...interests1].filter(i => interests2.has(i)).length;
    const maxInterests = Math.max(interests1.size, interests2.size, 1);
    score += (commonInterests / maxInterests) * 30;

    // Questionnaire similarity (40 points)
    if (q1.length > 0 && q2.length > 0) {
        const minLen = Math.min(q1.length, q2.length);
        let similarity = 0;
        for (let i = 0; i < minLen; i++) {
            const diff = Math.abs(q1[i] - q2[i]);
            similarity += (4 - diff) / 4;
        }
        score += (similarity / minLen) * 40;
    } else {
        score += 20; // Default if no questionnaire
    }

    // Location match (15 points)
    if (user1.city === user2.city) {
        score += 15;
    }

    // Both verified (10 points)
    if (user1.isVerified && user2.isVerified) {
        score += 10;
    }

    // Activity bonus (5 points)
    const oneWeekAgo = Date.now() - 7 * 24 * 60 * 60 * 1000;
    if (user2.lastActiveAt?.toMillis() > oneWeekAgo) {
        score += 5;
    }

    return Math.round(score);
}

function getWeekNumber(): number {
    const now = new Date();
    const start = new Date(now.getFullYear(), 0, 1);
    const diff = now.getTime() - start.getTime();
    const oneWeek = 604800000;
    return Math.ceil(diff / oneWeek);
}

async function sendNewMatchesNotification(fcmToken: string, count: number): Promise<void> {
    try {
        await admin.messaging().send({
            token: fcmToken,
            notification: {
                title: '✨ New matches are here!',
                body: `You have ${count} new curated matches this week. Open SPARK to see them!`,
            },
            data: {
                type: 'new_matches',
            },
            android: {
                priority: 'high',
                notification: {
                    channelId: 'matches',
                    icon: 'ic_notification',
                },
            },
            apns: {
                payload: {
                    aps: {
                        badge: count,
                        sound: 'default',
                    },
                },
            },
        });
    } catch (error) {
        console.error('Error sending notification:', error);
    }
}
