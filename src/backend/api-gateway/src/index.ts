/**
 * Human Tasks:
 * 1. Configure environment variables in .env file:
 *    - PORT: API Gateway port number
 *    - NODE_ENV: Environment (development, production)
 *    - LOG_LEVEL: Logging level (info, debug, error)
 *    - AUTH_SECRET: JWT authentication secret
 *    - RATE_LIMIT_WINDOW: Rate limiting window in minutes
 *    - RATE_LIMIT_MAX_REQUESTS: Maximum requests per window
 * 2. Set up monitoring and alerting for API Gateway health
 * 3. Configure proper CORS settings for production
 * 4. Review and adjust rate limiting settings based on load testing
 */

// express v4.18.2
import express, { Express, Request, Response, NextFunction } from 'express';
import cors from 'cors'; // v2.8.5
import helmet from 'helmet'; // v6.0.1
import compression from 'compression'; // v1.7.4
import morgan from 'morgan'; // v1.10.0

// Import configuration and middleware
import { loadConfig } from './config';
import { authenticateRequest, authorizeRequest } from './middleware/auth';
import { rateLimitMiddleware } from './middleware/rateLimit';
import { validateRequest } from './middleware/validation';
import { registerAllRoutes } from './routes';
import { createHttpError } from '../../shared/utils/error';
import logger from '../../shared/utils/logger';

/**
 * @description Initializes the API Gateway server with middleware, routes, and error handling
 * Addresses requirement: Technical Specification/8.3 API Design/8.3.1 API Architecture
 * Ensures the API Gateway is properly initialized with middleware and routes
 */
export const initializeServer = async (): Promise<void> => {
  try {
    // Load configuration settings
    const config = loadConfig();
    logger.logInfo('Starting API Gateway initialization');

    // Create Express application
    const app: Express = express();

    // Apply security middleware
    app.use(helmet());
    app.use(cors({
      origin: process.env.NODE_ENV === 'production' 
        ? process.env.ALLOWED_ORIGINS?.split(',') 
        : '*',
      methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization'],
      credentials: true,
      maxAge: 86400 // 24 hours
    }));

    // Apply utility middleware
    app.use(compression());
    app.use(express.json({ limit: '10mb' }));
    app.use(express.urlencoded({ extended: true, limit: '10mb' }));
    app.use(morgan('combined'));

    // Apply rate limiting middleware
    app.use(rateLimitMiddleware());

    // Health check endpoint (no auth required)
    app.get('/health', (req: Request, res: Response) => {
      res.status(200).json({ status: 'healthy', timestamp: new Date().toISOString() });
    });

    // Register all API routes
    registerAllRoutes(app);

    // Global error handling middleware
    app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
      logger.logError('Unhandled error in API Gateway', {
        error: err,
        path: req.path,
        method: req.method,
        requestId: req.headers['x-request-id']
      });

      const statusCode = err instanceof createHttpError.HttpError ? err.status : 500;
      const errorMessage = process.env.NODE_ENV === 'production' && statusCode === 500
        ? 'Internal Server Error'
        : err.message;

      res.status(statusCode).json({
        success: false,
        error: {
          message: errorMessage,
          ...(process.env.NODE_ENV !== 'production' && { stack: err.stack })
        }
      });
    });

    // Handle 404 errors for unmatched routes
    app.use((req: Request, res: Response) => {
      logger.logError('Route not found', {
        path: req.path,
        method: req.method,
        requestId: req.headers['x-request-id']
      });

      res.status(404).json({
        success: false,
        error: {
          message: 'Route not found'
        }
      });
    });

    // Start the server
    const port = config.port || 3000;
    app.listen(port, () => {
      logger.logInfo('API Gateway initialized successfully', {
        port,
        nodeEnv: process.env.NODE_ENV,
        logLevel: process.env.LOG_LEVEL
      });
    });

  } catch (error) {
    logger.logError('Failed to initialize API Gateway', { error });
    process.exit(1);
  }
};

// Start the server if this file is run directly
if (require.main === module) {
  initializeServer().catch((error) => {
    logger.logError('Failed to start API Gateway', { error });
    process.exit(1);
  });
}