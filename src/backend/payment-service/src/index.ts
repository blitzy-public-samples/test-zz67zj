/**
 * Human Tasks:
 * 1. Ensure proper environment variables are set up in production
 * 2. Configure monitoring and alerting for service health
 * 3. Set up proper logging infrastructure
 * 4. Review and adjust security measures for production deployment
 * 5. Configure rate limiting and DDoS protection
 */

// express v4.18.2
import express from 'express';
import { loadConfig } from './config';
import { initializeStripe } from './services/stripe';
import { setupRoutes } from './routes';
import logger from '../../../shared/utils/logger';
import { handleError } from '../../../shared/utils/error';

/**
 * @description Initializes and starts the Payment Service
 * Addresses requirement: Technical Specification/1.3 Scope/Core Features/Payments
 * Implements secure payment processing, refunds, and webhook handling
 */
export const startServer = async (): Promise<void> => {
    try {
        // Load configuration settings
        const config = loadConfig();
        logger.logInfo('Configuration loaded successfully', {
            nodeEnv: config.nodeEnv,
            port: config.port
        });

        // Initialize Stripe client
        initializeStripe();
        logger.logInfo('Stripe client initialized successfully');

        // Create Express application
        const app = express();

        // Configure middleware
        app.use(express.json());
        app.use(express.urlencoded({ extended: true }));

        // Add security headers
        app.use((req, res, next) => {
            res.setHeader('X-Content-Type-Options', 'nosniff');
            res.setHeader('X-Frame-Options', 'DENY');
            res.setHeader('X-XSS-Protection', '1; mode=block');
            res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
            next();
        });

        // Set up routes
        setupRoutes(app);

        // Global error handler
        app.use((err: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
            handleError(err, res);
        });

        // Start the server
        app.listen(config.port, () => {
            logger.logInfo(`Payment Service started successfully`, {
                port: config.port,
                environment: config.nodeEnv
            });
        });

        // Handle uncaught exceptions
        process.on('uncaughtException', (error: Error) => {
            logger.logError('Uncaught Exception', { error });
            process.exit(1);
        });

        // Handle unhandled promise rejections
        process.on('unhandledRejection', (reason: any) => {
            logger.logError('Unhandled Promise Rejection', { reason });
            process.exit(1);
        });

        // Handle termination signals
        process.on('SIGTERM', () => {
            logger.logInfo('SIGTERM received, shutting down gracefully');
            process.exit(0);
        });

        process.on('SIGINT', () => {
            logger.logInfo('SIGINT received, shutting down gracefully');
            process.exit(0);
        });

    } catch (error) {
        logger.logError('Failed to start Payment Service', {
            error: error instanceof Error ? error.message : 'Unknown error'
        });
        process.exit(1);
    }
};

// Start the server if this file is run directly
if (require.main === module) {
    startServer();
}