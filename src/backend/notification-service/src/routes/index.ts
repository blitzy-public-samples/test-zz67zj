/**
 * Human Tasks:
 * 1. Ensure rate limiting middleware is properly configured for production use
 * 2. Set up API monitoring and alerting for notification endpoints
 * 3. Configure appropriate CORS settings for the routes
 * 4. Implement request validation middleware if needed
 */

// express v4.18.2
import { Router, Request, Response, NextFunction } from 'express';
import { sendNotification } from '../controllers/notification';
import logger from '../../../shared/utils/logger';
import { createHttpError } from '../../../shared/utils/error';

/**
 * @description Interface for notification request body
 */
interface NotificationRequest {
  type: 'email' | 'push';
  recipient: string;
  subject?: string;
  body: string;
  data?: Record<string, string>;
  priority?: 'high' | 'normal';
  imageUrl?: string;
}

/**
 * @description Initializes the notification-related routes for the Notification Service.
 * Addresses requirement: Notification Routing (7.2.1 Core Components/Notification Service)
 * @param router - Express Router instance
 */
export const initializeRoutes = (router: Router): void => {
  // Log route initialization
  logger.logInfo('Initializing notification routes', {
    service: 'notification-service',
    component: 'routes'
  });

  // POST /send - Send a notification
  router.post('/send', async (req: Request, res: Response, next: NextFunction) => {
    try {
      const notificationRequest = req.body as NotificationRequest;

      // Validate request body
      if (!notificationRequest || !notificationRequest.type || !notificationRequest.recipient) {
        throw createHttpError(400, 'Invalid request body. Required fields: type, recipient');
      }

      // Log notification request
      logger.logInfo('Received notification request', {
        type: notificationRequest.type,
        recipient: notificationRequest.recipient,
        subject: notificationRequest.subject
      });

      // Send notification using the controller
      await sendNotification(
        notificationRequest.type,
        {
          recipient: notificationRequest.recipient,
          subject: notificationRequest.subject,
          body: notificationRequest.body,
          data: notificationRequest.data,
          priority: notificationRequest.priority,
          imageUrl: notificationRequest.imageUrl
        }
      );

      // Send success response
      res.status(200).json({
        success: true,
        message: 'Notification sent successfully'
      });

    } catch (error) {
      // Pass error to error handling middleware
      next(error);
    }
  });

  // Error handling middleware
  router.use((error: Error, req: Request, res: Response, next: NextFunction) => {
    // Log error
    logger.logError('Error in notification routes', {
      error,
      path: req.path,
      method: req.method
    });

    // If error is already an HTTP error, use its status code
    const statusCode = (error as any).status || 500;
    const message = error.message || 'Internal server error';

    // Send error response
    res.status(statusCode).json({
      success: false,
      error: {
        code: statusCode,
        message: message
      }
    });
  });

  logger.logInfo('Notification routes initialized successfully', {
    service: 'notification-service',
    component: 'routes'
  });
};