/**
 * Human Tasks:
 * 1. Configure rate limiting for user registration endpoints
 * 2. Set up monitoring for registration failures and suspicious activities
 * 3. Configure user data encryption settings in environment variables
 * 4. Set up proper database indexes for user queries
 */

// express v4.18.2
import { Router, Request, Response, NextFunction } from 'express';
import { User } from '../../../shared/models/user';
import { validateUser } from '../../../shared/utils/validation';
import { authenticateRequest, authorizeRequest } from '../middleware/auth';
import { validateRequest } from '../middleware/validation';
import { createHttpError } from '../../../shared/utils/error';
import logger from '../../../shared/utils/logger';

/**
 * @description Router instance for handling user-related API routes
 * Addresses requirement: Technical Specification/8.3 API Design/8.3.2 API Specifications
 */
const router = Router();

/**
 * @description Handles user registration requests
 * Addresses requirement: Technical Specification/8.3 API Design/8.3.2 API Specifications
 * Provides endpoint for creating new user accounts with proper validation
 */
export const registerUserRoute = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    logger.logInfo('Processing user registration request', {
      email: req.body.email,
      requestId: req.headers['x-request-id']
    });

    // Create a new user instance from request body
    const newUser = new User(
      req.body.id,
      req.body.email,
      req.body.password,
      req.body.name,
      new Date(),
      new Date()
    );

    // Validate user data
    await validateUser(newUser);

    // Log successful validation
    logger.logInfo('User data validation successful', {
      userId: newUser.id,
      email: newUser.email,
      requestId: req.headers['x-request-id']
    });

    // Send success response
    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: {
        id: newUser.id,
        email: newUser.email,
        name: newUser.name,
        createdAt: newUser.createdAt
      }
    });
  } catch (error) {
    logger.logError('User registration failed', {
      error,
      requestId: req.headers['x-request-id']
    });
    next(error);
  }
};

/**
 * @description Retrieves user profile information
 * Addresses requirement: Technical Specification/8.3 API Design/8.3.2 API Specifications
 * Provides authenticated access to user profile data
 */
export const getUserProfileRoute = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    // Ensure request is authenticated and user context exists
    if (!req.user?.id) {
      throw createHttpError(401, 'Authentication required');
    }

    logger.logInfo('Processing get user profile request', {
      userId: req.user.id,
      requestId: req.headers['x-request-id']
    });

    // Send user profile data
    res.status(200).json({
      success: true,
      data: {
        id: req.user.id,
        email: req.user.email,
        name: req.user.name
      }
    });
  } catch (error) {
    logger.logError('Failed to retrieve user profile', {
      error,
      userId: req.user?.id,
      requestId: req.headers['x-request-id']
    });
    next(error);
  }
};

// Register routes
router.post(
  '/register',
  validateRequest(User),
  registerUserRoute
);

router.get(
  '/profile',
  authenticateRequest,
  authorizeRequest(['user', 'admin']),
  getUserProfileRoute
);

// Export the router with named routes
export const userRoutes = router;