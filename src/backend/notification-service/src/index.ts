/**
 * Human Tasks:
 * 1. Ensure all required environment variables are properly configured
 * 2. Verify network and firewall settings allow required service connections
 * 3. Set up monitoring and alerting for the service
 * 4. Configure appropriate logging levels for the environment
 */

// express v4.18.2
import express from 'express';
import { loadConfig } from './config';
import { initializeEmailService } from './services/email';
import { initializeFirebase } from './services/push';
import { initializeRoutes } from './routes';
import { logInfo, logError } from '../../shared/utils/logger';

/**
 * Initializes the Notification Service by setting up configurations, services, and routes.
 * Addresses requirement: Notification Service Initialization (7.2.1 Core Components/Notification Service)
 * Ensures proper initialization of all required components for notification handling.
 */
export const initializeNotificationService = async (): Promise<void> => {
  try {
    // Load configuration settings
    const config = loadConfig();
    logInfo('Configuration loaded successfully', {
      service: 'notification-service',
      port: config.server.port,
      host: config.server.host
    });

    // Initialize email service
    await initializeEmailService();
    logInfo('Email service initialized successfully', {
      service: 'notification-service',
      component: 'email-service'
    });

    // Initialize Firebase for push notifications
    initializeFirebase();
    logInfo('Firebase service initialized successfully', {
      service: 'notification-service',
      component: 'push-service'
    });

    // Create Express application
    const app = express();

    // Configure middleware
    app.use(express.json({ limit: '1mb' }));
    app.use(express.urlencoded({ extended: true }));

    // Add basic security headers
    app.use((req, res, next) => {
      res.setHeader('X-Content-Type-Options', 'nosniff');
      res.setHeader('X-Frame-Options', 'DENY');
      res.setHeader('X-XSS-Protection', '1; mode=block');
      next();
    });

    // Initialize routes
    const router = express.Router();
    initializeRoutes(router);
    app.use('/api/notifications', router);

    // Start server
    app.listen(config.server.port, config.server.host, () => {
      logInfo('Notification Service started successfully', {
        service: 'notification-service',
        port: config.server.port,
        host: config.server.host,
        environment: process.env.NODE_ENV || 'development'
      });
    });

  } catch (error) {
    logError('Failed to initialize Notification Service', {
      error,
      service: 'notification-service'
    });
    process.exit(1);
  }
};

// Start the service if this file is run directly
if (require.main === module) {
  initializeNotificationService().catch((error) => {
    logError('Unhandled error during service initialization', {
      error,
      service: 'notification-service'
    });
    process.exit(1);
  });
}