import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Initialize Firebase Admin
admin.initializeApp();

// Export services
export * from './services/user-service';
export * from './services/matching-service';
export * from './services/chat-service';
export * from './scheduled/weekly-matches';
export * from './scheduled/room-expiry';
