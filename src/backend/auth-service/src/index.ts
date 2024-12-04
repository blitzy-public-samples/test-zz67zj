/**
 * Human Tasks:
 * 1. Configure environment variables:
 *    - PORT (default: 3000)
 *    - JWT_SECRET (required, no default)
 * 2. Set up monitoring and alerting for server health
 * 3. Configure proper CORS settings for production
 * 4. Review and adjust rate limiting settings based on load testing
 */

// express ^4.18.2
import express, { Request, Response, NextFunction } from 'express';
// http-errors ^2.0.0
import createError from 'http-errors';
// Import configuration using relative path
import config, { PORT, JWT_SECRET } from './config';
// Import routes using relative path
import router from './routes';
import logger from '../../../shared/utils/logger';

/**
 * Initializes and starts the Express server for the authentication service.
 * Addresses requirement: Technical Specification/10.1 Authentication and Authorization
 * Provides a secure and scalable entry point for the authentication service.
 */
export const initializeServer = async (): Promise<void> => {
  try {
    // Create Express application instance
    const app = express();

    // Basic security middleware
    app.disable('x-powered-by');
    app.use(express.json({ limit: '10kb' })); // Limit payload size
    app.use(express.urlencoded({ extended: true, limit: '10kb' }));

    // Add request logging middleware
    app.use((req: Request, _res: Response, next: NextFunction) => {
      logger.logInfo('Incoming request', {
        method: req.method,
        path: req.path,
        ip: req.ip,
        userAgent: req.get('user-agent')
      });
      next();
    });

    // Validate required configuration
    if (!JWT_SECRET) {
      throw new Error('JWT_SECRET is required but not configured');
    }

    // Mount authentication routes
    app.use('/api/auth', router);

    // 404 handler
    app.use((_req: Request, _res: Response, next: NextFunction) => {
      next(createError(404, 'Route not found'));
    });

    // Global error handler
    app.use((err: any, req: Request, res: Response, _next: NextFunction) => {
      logger.logError('Unhandled error', {
        error: err,
        path: req.path,
        method: req.method
      });

      const statusCode = err.status || 500;
      const message = err.message || 'Internal Server Error';

      res.status(statusCode).json({
        success: false,
        error: {
          code: statusCode,
          message,
          ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
        }
      });
    });

    // Start the server
    app.listen(PORT, () => {
      logger.logInfo('Authentication service started', {
        port: PORT,
        environment: process.env.NODE_ENV || 'development',
        timestamp: new Date().toISOString()
      });
    });
  } catch (error) {
    logger.logError('Failed to start authentication service', { error });
    process.exit(1);
  }
};

// Start the server if this file is run directly
if (require.main === module) {
  initializeServer().catch((error) => {
    logger.logError('Fatal error during server initialization', { error });
    process.exit(1);
  });
}

export default initializeServer;