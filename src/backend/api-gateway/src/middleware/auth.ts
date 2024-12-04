/**
 * Human Tasks:
 * 1. Set up JWT secret key in environment variables (JWT_SECRET)
 * 2. Configure token expiration time in environment variables (JWT_EXPIRATION)
 * 3. Set up monitoring for authentication failures and suspicious activities
 * 4. Configure rate limiting for authentication endpoints
 * 5. Implement token refresh mechanism if required
 */

// jsonwebtoken v9.0.0
import { Request, Response, NextFunction } from 'express';
import { authenticateToken, authorizeRole } from '../../../shared/middleware/auth';
import logger from '../../../shared/utils/logger';
import { createHttpError } from '../../../shared/utils/error';
import { validateModel } from '../../../shared/utils/validation';

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
 * @description Middleware function to authenticate API Gateway requests using JWT
 * Addresses requirement: Technical Specification/10.1 Authentication and Authorization
 * Ensures secure authentication for API Gateway requests
 * 
 * @param req - Express request object
 * @param res - Express response object
 * @param next - Express next function
 */
export const authenticateRequest = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    // Extract the authorization header
    const authHeader = req.headers['authorization'];
    
    if (!authHeader) {
      logger.logError('Authentication failed - No authorization header', {
        path: req.path,
        method: req.method,
        ip: req.ip
      });
      throw createHttpError(401, 'Authentication required');
    }

    // Use the shared authentication middleware
    await authenticateToken(req, res, next);

    // Log successful authentication
    logger.logInfo('Authentication successful', {
      userId: req.user?.id,
      path: req.path,
      method: req.method
    });
  } catch (error) {
    logger.logError('Authentication failed in API Gateway', {
      error,
      path: req.path,
      method: req.method,
      ip: req.ip
    });
    next(error);
  }
};

/**
 * @description Middleware factory function for role-based authorization in API Gateway
 * Addresses requirement: Technical Specification/10.1 Authentication and Authorization
 * Ensures proper authorization based on user roles
 * 
 * @param allowedRoles - Array of roles that are allowed to access the route
 * @returns Middleware function for role-based authorization
 */
export const authorizeRequest = (allowedRoles: string[]) => {
  return async (
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    try {
      // Validate the allowed roles array
      if (!Array.isArray(allowedRoles) || allowedRoles.length === 0) {
        logger.logError('Invalid allowed roles configuration', {
          allowedRoles,
          path: req.path,
          method: req.method
        });
        throw createHttpError(500, 'Invalid authorization configuration');
      }

      // Use the shared authorization middleware
      const authMiddleware = authorizeRole(allowedRoles);
      await authMiddleware(req, res, next);

      // Log successful authorization
      logger.logInfo('Authorization successful', {
        userId: req.user?.id,
        userRole: req.user?.role,
        allowedRoles,
        path: req.path,
        method: req.method
      });
    } catch (error) {
      logger.logError('Authorization failed in API Gateway', {
        error,
        userId: req.user?.id,
        userRole: req.user?.role,
        allowedRoles,
        path: req.path,
        method: req.method
      });
      next(error);
    }
  };
};