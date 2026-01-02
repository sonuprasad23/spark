/**
 * SPARK User Service - Cloud Functions
 * Handles user registration, profile updates, and verification
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();
const USERS_COLLECTION = 'users';
const PREFERENCES_COLLECTION = 'preferences';

// User interface
interface SparkUser {
    id: string;
    phoneNumber: string;
    email?: string;
    name: string;
    age: number;
    gender: 'male' | 'female' | 'non-binary';
    city: string;
    coordinates?: admin.firestore.GeoPoint;
    photos: string[];
    bio: string;
    interests: string[];
    prompts: Record<string, string>;
    questionnaireAnswers?: number[];
    isVerified: boolean;
    isPremium: boolean;
    premiumTier?: 'plus' | 'pro';
    premiumExpiresAt?: admin.firestore.Timestamp;
    matchesPerWeek: number;
    profileCompleteness: number;
    createdAt: admin.firestore.Timestamp;
    updatedAt: admin.firestore.Timestamp;
    lastActiveAt: admin.firestore.Timestamp;
    isActive: boolean;
}

interface UserPreferences {
    userId: string;
    lookingFor: 'male' | 'female' | 'both';
    ageRange: { min: number; max: number };
    maxDistance: number; // in km
    cities: string[];
}

/**
 * Create new user profile after authentication
 */
export const createUserProfile = functions.https.onCall(async (data, context) => {
    // Verify authentication
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    }

    const userId = context.auth.uid;
    const phoneNumber = context.auth.token.phone_number;

    try {
        // Check if user already exists
        const existingUser = await db.collection(USERS_COLLECTION).doc(userId).get();
        if (existingUser.exists) {
            throw new functions.https.HttpsError('already-exists', 'User profile already exists');
        }

        // Validate required fields
        const { name, age, gender, city, lookingFor } = data;
        if (!name || !age || !gender || !city || !lookingFor) {
            throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
        }

        // Create user profile
        const now = admin.firestore.Timestamp.now();
        const userProfile: SparkUser = {
            id: userId,
            phoneNumber: phoneNumber || '',
            name: name,
            age: age,
            gender: gender,
            city: city,
            photos: [],
            bio: '',
            interests: [],
            prompts: {},
            isVerified: false,
            isPremium: false,
            matchesPerWeek: 5, // Free tier default
            profileCompleteness: 30, // Basic info only
            createdAt: now,
            updatedAt: now,
            lastActiveAt: now,
            isActive: true,
        };

        // Create preferences
        const preferences: UserPreferences = {
            userId: userId,
            lookingFor: lookingFor,
            ageRange: { min: 18, max: 30 },
            maxDistance: 50,
            cities: [city],
        };

        // Save to Firestore
        const batch = db.batch();
        batch.set(db.collection(USERS_COLLECTION).doc(userId), userProfile);
        batch.set(db.collection(PREFERENCES_COLLECTION).doc(userId), preferences);
        await batch.commit();

        return { success: true, userId };
    } catch (error) {
        console.error('Error creating user profile:', error);
        throw new functions.https.HttpsError('internal', 'Failed to create profile');
    }
});

/**
 * Update user profile
 */
export const updateUserProfile = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    }

    const userId = context.auth.uid;

    try {
        const userRef = db.collection(USERS_COLLECTION).doc(userId);
        const userDoc = await userRef.get();

        if (!userDoc.exists) {
            throw new functions.https.HttpsError('not-found', 'User profile not found');
        }

        // Calculate profile completeness
        const completeness = calculateProfileCompleteness({
            ...userDoc.data(),
            ...data,
        });

        // Update user profile
        await userRef.update({
            ...data,
            profileCompleteness: completeness,
            updatedAt: admin.firestore.Timestamp.now(),
        });

        return { success: true, profileCompleteness: completeness };
    } catch (error) {
        console.error('Error updating user profile:', error);
        throw new functions.https.HttpsError('internal', 'Failed to update profile');
    }
});

/**
 * Upload and save photo URL
 */
export const addUserPhoto = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    }

    const userId = context.auth.uid;
    const { photoUrl, index } = data;

    if (!photoUrl || index === undefined) {
        throw new functions.https.HttpsError('invalid-argument', 'Missing photo URL or index');
    }

    try {
        const userRef = db.collection(USERS_COLLECTION).doc(userId);
        const userDoc = await userRef.get();
        const userData = userDoc.data();

        if (!userData) {
            throw new functions.https.HttpsError('not-found', 'User not found');
        }

        const photos = userData.photos || [];

        // Limit to 6 photos
        if (index >= 6) {
            throw new functions.https.HttpsError('invalid-argument', 'Maximum 6 photos allowed');
        }

        // Update photos array
        if (index < photos.length) {
            photos[index] = photoUrl;
        } else {
            photos.push(photoUrl);
        }

        await userRef.update({
            photos,
            profileCompleteness: calculateProfileCompleteness({ ...userData, photos }),
            updatedAt: admin.firestore.Timestamp.now(),
        });

        return { success: true, photos };
    } catch (error) {
        console.error('Error adding photo:', error);
        throw new functions.https.HttpsError('internal', 'Failed to add photo');
    }
});

/**
 * Verify user profile (admin or automated)
 */
export const verifyUser = functions.https.onCall(async (data, context) => {
    // This would typically be called by admin or automated verification system
    const { userId, verified } = data;

    try {
        await db.collection(USERS_COLLECTION).doc(userId).update({
            isVerified: verified,
            updatedAt: admin.firestore.Timestamp.now(),
        });

        return { success: true };
    } catch (error) {
        console.error('Error verifying user:', error);
        throw new functions.https.HttpsError('internal', 'Failed to verify user');
    }
});

/**
 * Get user profile
 */
export const getUserProfile = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    }

    const userId = data.userId || context.auth.uid;

    try {
        const userDoc = await db.collection(USERS_COLLECTION).doc(userId).get();

        if (!userDoc.exists) {
            throw new functions.https.HttpsError('not-found', 'User not found');
        }

        const userData = userDoc.data();

        // If requesting own profile, return full data
        if (userId === context.auth.uid) {
            return userData;
        }

        // If viewing another user, return limited data
        return {
            id: userData?.id,
            name: userData?.name,
            age: userData?.age,
            city: userData?.city,
            photos: userData?.photos,
            bio: userData?.bio,
            interests: userData?.interests,
            prompts: userData?.prompts,
            isVerified: userData?.isVerified,
        };
    } catch (error) {
        console.error('Error getting user profile:', error);
        throw new functions.https.HttpsError('internal', 'Failed to get profile');
    }
});

/**
 * Update last active timestamp
 */
export const updateLastActive = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    }

    try {
        await db.collection(USERS_COLLECTION).doc(context.auth.uid).update({
            lastActiveAt: admin.firestore.Timestamp.now(),
        });

        return { success: true };
    } catch (error) {
        console.error('Error updating last active:', error);
        throw new functions.https.HttpsError('internal', 'Failed to update');
    }
});

/**
 * Calculate profile completeness percentage
 */
function calculateProfileCompleteness(userData: Partial<SparkUser>): number {
    let score = 0;
    const maxScore = 100;

    // Basic info (30%)
    if (userData.name) score += 10;
    if (userData.age) score += 5;
    if (userData.gender) score += 5;
    if (userData.city) score += 10;

    // Photos (30%)
    const photoCount = userData.photos?.length || 0;
    score += Math.min(photoCount * 5, 30);

    // Bio (15%)
    if (userData.bio && userData.bio.length > 50) score += 15;
    else if (userData.bio && userData.bio.length > 0) score += 10;

    // Interests (10%)
    const interestCount = userData.interests?.length || 0;
    if (interestCount >= 5) score += 10;
    else score += interestCount * 2;

    // Prompts (10%)
    const promptCount = Object.keys(userData.prompts || {}).length;
    if (promptCount >= 3) score += 10;
    else score += promptCount * 3;

    // Verification (5%)
    if (userData.isVerified) score += 5;

    return Math.min(score, maxScore);
}
