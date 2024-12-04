/**
 * Human Tasks:
 * 1. Ensure email service is properly initialized before sending notifications
 * 2. Verify Firebase Admin SDK is initialized for push notifications
 * 3. Configure appropriate rate limiting for notification endpoints
 * 4. Set up monitoring for notification delivery success rates
 */

import { sendEmail } from '../services/email';
import { sendPushNotification } from '../services/push';
import logger from '../../../shared/utils/logger';
import { createHttpError } from '../../../shared/utils/error';

/**
 * Interface for notification payload
 */
interface NotificationPayload {
  recipient: string;
  subject?: string;
  body: string;
  data?: Record<string, string>;
  priority?: 'high' | 'normal';
  imageUrl?: string;
}

/**
 * @description Handles the logic for sending notifications via email or push based on the provided type.
 * Addresses requirement: Notification Management (7.2.1 Core Components/Notification Service)
 * 
 * @param type - The type of notification to send ('email' or 'push')
 * @param payload - The notification content and configuration
 * @returns Promise<void> - Resolves when the notification is successfully sent
 * @throws HttpError if notification sending fails or if type is invalid
 */
export const sendNotification = async (
  type: string,
  payload: NotificationPayload
): Promise<void> => {
  try {
    // Log notification attempt
    logger.logInfo('Attempting to send notification', {
      type,
      recipient: payload.recipient,
      subject: payload.subject,
    });

    // Validate notification type
    if (!['email', 'push'].includes(type)) {
      throw createHttpError(400, 'Invalid notification type. Must be either "email" or "push"');
    }

    // Validate payload
    if (!payload.recipient) {
      throw createHttpError(400, 'Recipient is required');
    }
    if (!payload.body) {
      throw createHttpError(400, 'Notification body is required');
    }

    // Send notification based on type
    switch (type) {
      case 'email':
        if (!payload.subject) {
          throw createHttpError(400, 'Subject is required for email notifications');
        }
        await sendEmail(
          payload.recipient,
          payload.subject,
          payload.body
        );
        break;

      case 'push':
        await sendPushNotification(
          payload.recipient,
          {
            title: payload.subject || 'New Notification',
            body: payload.body,
            data: payload.data,
            priority: payload.priority,
            imageUrl: payload.imageUrl,
          }
        );
        break;
    }

    // Log successful notification
    logger.logInfo('Notification sent successfully', {
      type,
      recipient: payload.recipient,
      subject: payload.subject,
    });

  } catch (error) {
    // Log error details
    logger.logError('Failed to send notification', {
      error,
      type,
      recipient: payload.recipient,
      subject: payload.subject,
    });

    // If the error is already an HTTP error, rethrow it
    if (error.status) {
      throw error;
    }

    // Otherwise, create a new HTTP error
    throw createHttpError(
      500,
      'Failed to send notification'
    );
  }
};