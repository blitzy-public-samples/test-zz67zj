/**
 * Human Tasks:
 * 1. Configure rate limiting for authentication endpoints
 * 2. Set up monitoring for authentication failures
 * 3. Configure CORS settings for authentication endpoints
 * 4. Review and adjust error handling strategies based on security policies
 */

// express v4.18.2
import { Router } from 'express';

// Import authentication middleware and controllers
import { authenticateToken, authorizeRole } from '../../../shared/middleware/auth';
import { createHttpError } from '../../../shared/utils/error';
import logger from '../../../shared/utils/logger';
import { validateRequest } from '../middleware/validation';
import { login, register, verify } from '../../../auth-service/src/controllers/auth';

/**
 * Sets up authentication routes for the API Gateway.
 * Addresses requirement: Technical Specification/10.1 Authentication and Authorization
 * Provides endpoints for user login, registration, and session management.
 * 
 * @param router - Express Router instance
 */
export const setupAuthRoutes = (router: Router): void => {
  try {
    logger.logInfo('Setting up authentication routes');

    // User registration endpoint
    router.post(
      '/register',
      validateRequest(AuthUser), // Validate request body against AuthUser schema
      async (req, res) => {
        try {
          await register(req, res);
        } catch (error) {
          logger.logError('Registration route error', { error });
          throw createHttpError(500, 'Registration failed');
        }
      }
    );

    // User login endpoint
    router.post(
      '/login',
      validateRequest(AuthUser), // Validate request body against AuthUser schema
      async (req, res) => {
        try {
          await login(req, res);
        } catch (error) {
          logger.logError('Login route error', { error });
          throw createHttpError(500, 'Login failed');
        }
      }
    );

    // Session verification endpoint
    router.get(
      '/verify',
      authenticateToken, // Verify JWT token
      async (req, res) => {
        try {
          await verify(req, res);
        } catch (error) {
          logger.logError('Verification route error', { error });
          throw createHttpError(500, 'Verification failed');
        }
      }
    );

    logger.logInfo('Authentication routes setup completed successfully');
  } catch (error) {
    logger.logError('Failed to set up authentication routes', { error });
    throw error;
  }
};