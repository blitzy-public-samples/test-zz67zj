/**
 * Human Tasks:
 * 1. Set up JWT secret key in environment variables (JWT_SECRET)
 * 2. Configure token expiration time in environment variables (JWT_EXPIRATION)
 * 3. Implement token refresh mechanism if required
 * 4. Set up monitoring for authentication failures and suspicious activities
 */

// jsonwebtoken v9.0.0
import jwt from 'jsonwebtoken';
import { Request, Response, NextFunction } from 'express';
import { createHttpError } from '../utils/error';
import logger from '../utils/logger';
import { validateModel } from '../utils/validation';
import { User } from '../models/user';

/**
 * Extended Request interface to include user information
 */
interface AuthenticatedRequest extends Request {
  user?: {
    id: string;
    email: string;
    role: string;
  };
}

/**
 * @description Middleware function to authenticate requests using JWT
 * Addresses requirement: Technical Specification/10.1 Authentication and Authorization
 * Ensures secure authentication for protected routes
 * 
 * @param req - Express request object
 * @param res - Express response object
 * @param next - Express next function
 */
export const authenticateToken = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    // Extract the authorization header
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      logger.logError('Authentication failed - No token provided', {
        path: req.path,
        method: req.method
      });
      throw createHttpError(401, 'Authentication required');
    }

    // Verify the JWT token
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET!) as {
        id: string;
        email: string;
        role: string;
      };

      // Attach the decoded user information to the request object
      req.user = {
        id: decoded.id,
        email: decoded.email,
        role: decoded.role
      };

      // Validate the user data using the User model
      await validateModel(new User(
        decoded.id,
        decoded.email,
        '', // Password not needed for validation here
        '', // Name not needed for validation here
        new Date(),
        new Date()
      ));

      next();
    } catch (error) {
      logger.logError('Token verification failed', {
        error,
        path: req.path,
        method: req.method
      });
      throw createHttpError(403, 'Invalid or expired token');
    }
  } catch (error) {
    next(error);
  }
};

/**
 * @description Middleware factory function for role-based authorization
 * Addresses requirement: Technical Specification/10.1 Authentication and Authorization
 * Ensures proper authorization based on user roles
 * 
 * @param allowedRoles - Array of roles that are allowed to access the route
 * @returns Middleware function for role-based authorization
 */
export const authorizeRole = (allowedRoles: string[]) => {
  return async (
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    try {
      if (!req.user) {
        logger.logError('Authorization failed - No user context', {
          path: req.path,
          method: req.method
        });
        throw createHttpError(401, 'Authentication required');
      }

      if (!allowedRoles.includes(req.user.role)) {
        logger.logError('Authorization failed - Insufficient permissions', {
          userId: req.user.id,
          userRole: req.user.role,
          requiredRoles: allowedRoles,
          path: req.path,
          method: req.method
        });
        throw createHttpError(403, 'Insufficient permissions');
      }

      next();
    } catch (error) {
      next(error);
    }
  };
};