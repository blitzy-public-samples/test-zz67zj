/**
 * Human Tasks:
 * 1. Ensure Firebase Admin SDK credentials are properly configured in the environment
 * 2. Verify Firebase Cloud Messaging (FCM) is enabled in the Firebase Console
 * 3. Set up proper Firebase security rules for production environment
 * 4. Configure Firebase Admin SDK service account with minimum required permissions
 */

// firebase-admin v11.0.1
import * as admin from 'firebase-admin';
import { logInfo, logError } from '../../../shared/utils/logger';
import { createHttpError } from '../../../shared/utils/error';
import { User } from '../../../shared/models/user';
import { loadConfig } from '../config';

// Global variable for Firebase app instance
let firebaseApp: admin.app.App;

/**
 * @description Initializes the Firebase Admin SDK with the required configuration.
 * Addresses requirement: Technical Specification/7.2.1 Core Components/Notification Service
 * Ensures proper setup of push notification infrastructure.
 */
export const initializeFirebase = (): void => {
  try {
    const config = loadConfig();

    // Initialize Firebase Admin SDK if not already initialized
    if (!firebaseApp) {
      firebaseApp = admin.initializeApp({
        credential: admin.credential.cert({
          projectId: process.env.FIREBASE_PROJECT_ID,
          clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
          privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
        }),
        projectId: process.env.FIREBASE_PROJECT_ID,
      });

      logInfo('Firebase Admin SDK initialized successfully', {
        service: 'push-notification',
        projectId: process.env.FIREBASE_PROJECT_ID,
      });
    }
  } catch (error) {
    logError('Failed to initialize Firebase Admin SDK', {
      error,
      service: 'push-notification',
    });
    throw createHttpError(500, 'Push notification service initialization failed');
  }
};

/**
 * Interface for push notification payload
 */
interface NotificationPayload {
  title: string;
  body: string;
  data?: Record<string, string>;
  imageUrl?: string;
  priority?: 'high' | 'normal';
  ttl?: number;
}

/**
 * @description Sends a push notification to a specified user.
 * Addresses requirement: Technical Specification/7.2.1 Core Components/Notification Service
 * Implements real-time push notification delivery to users.
 * 
 * @param userId - The ID of the user to send the notification to
 * @param notificationPayload - The notification content and configuration
 * @returns Promise<void> - Resolves when notification is sent successfully
 * @throws HttpError if notification sending fails
 */
export const sendPushNotification = async (
  userId: string,
  notificationPayload: NotificationPayload
): Promise<void> => {
  try {
    // Validate user ID
    const user = new User(
      userId,
      '', // email not needed for this operation
      '', // password not needed for this operation
      '', // name not needed for this operation
      new Date(), // createdAt not needed for this operation
      new Date() // updatedAt not needed for this operation
    );
    await user.validate();

    // Log notification attempt
    logInfo('Attempting to send push notification', {
      userId,
      notificationTitle: notificationPayload.title,
      service: 'push-notification',
    });

    // Ensure Firebase is initialized
    if (!firebaseApp) {
      throw createHttpError(500, 'Push notification service not initialized');
    }

    // Prepare the message
    const message: admin.messaging.Message = {
      notification: {
        title: notificationPayload.title,
        body: notificationPayload.body,
        imageUrl: notificationPayload.imageUrl,
      },
      data: notificationPayload.data,
      android: {
        priority: notificationPayload.priority === 'high' ? 'high' : 'normal',
        ttl: notificationPayload.ttl ? notificationPayload.ttl * 1000 : undefined, // Convert to milliseconds
      },
      apns: {
        payload: {
          aps: {
            alert: {
              title: notificationPayload.title,
              body: notificationPayload.body,
            },
            sound: 'default',
          },
        },
      },
      token: userId, // Assuming userId is the FCM token
    };

    // Send the notification
    const response = await admin.messaging().send(message);

    // Log successful notification
    logInfo('Push notification sent successfully', {
      userId,
      messageId: response,
      service: 'push-notification',
    });
  } catch (error) {
    // Log error details
    logError('Failed to send push notification', {
      error,
      userId,
      service: 'push-notification',
    });

    // Handle specific Firebase errors
    if (error instanceof admin.messaging.FirebaseMessagingError) {
      switch (error.code) {
        case 'messaging/invalid-registration-token':
        case 'messaging/registration-token-not-registered':
          throw createHttpError(404, 'Invalid or unregistered device token');
        case 'messaging/message-rate-exceeded':
          throw createHttpError(429, 'Notification rate limit exceeded');
        default:
          throw createHttpError(500, 'Failed to send push notification');
      }
    }

    // Handle other errors
    throw createHttpError(500, 'Failed to send push notification');
  }
};