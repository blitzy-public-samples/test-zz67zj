/**
 * Human Tasks:
 * 1. Set up the JWT_SECRET environment variable with a secure random string
 * 2. Configure JWT token expiration time in environment variables (JWT_EXPIRATION)
 * 3. Implement token rotation strategy if required
 * 4. Set up monitoring for JWT-related operations
 */

// jsonwebtoken v9.0.0
import jwt from 'jsonwebtoken';
import { AuthUser } from '../models/user';
import logger from '../../../shared/utils/logger';
import { createHttpError } from '../../../shared/utils/error';

// JWT configuration
const JWT_SECRET = process.env.JWT_SECRET;
const JWT_EXPIRATION = process.env.JWT_EXPIRATION || '1h';

/**
 * Generates a JWT for a given user.
 * Addresses requirement: Technical Specification/10.1 Authentication and Authorization
 * Ensures secure token-based authentication for users.
 * 
 * @param user - The authenticated user object
 * @returns A signed JWT string
 * @throws HttpError if user validation fails or token generation fails
 */
export const generateToken = async (user: AuthUser): Promise<string> => {
  try {
    // Validate the user object before generating token
    await user.validate();

    // Prepare the payload with essential user information
    const payload = {
      userId: user.id,
      email: user.email,
      name: user.name,
      // Add additional claims as needed
      iat: Math.floor(Date.now() / 1000),
    };

    // Check if JWT_SECRET is configured
    if (!JWT_SECRET) {
      logger.logError('JWT_SECRET environment variable is not configured');
      throw createHttpError(500, 'Token generation failed due to configuration error');
    }

    // Sign the token with the secret key
    const token = jwt.sign(payload, JWT_SECRET, {
      expiresIn: JWT_EXPIRATION,
      algorithm: 'HS256' // Using HMAC SHA256 algorithm
    });

    logger.logInfo('JWT token generated successfully', {
      userId: user.id,
      tokenExp: JWT_EXPIRATION
    });

    return token;
  } catch (error) {
    logger.logError('Failed to generate JWT token', {
      userId: user.id,
      error
    });

    if (error instanceof jwt.JsonWebTokenError) {
      throw createHttpError(500, 'Failed to generate authentication token');
    }

    // Re-throw other errors (like validation errors)
    throw error;
  }
};

/**
 * Verifies a JWT and extracts its payload.
 * Addresses requirement: Technical Specification/10.1 Authentication and Authorization
 * Ensures secure token-based authentication for users.
 * 
 * @param token - The JWT string to verify
 * @returns The decoded token payload
 * @throws HttpError if token is invalid or verification fails
 */
export const verifyToken = (token: string): jwt.JwtPayload => {
  try {
    // Check if JWT_SECRET is configured
    if (!JWT_SECRET) {
      logger.logError('JWT_SECRET environment variable is not configured');
      throw createHttpError(500, 'Token verification failed due to configuration error');
    }

    // Verify and decode the token
    const decoded = jwt.verify(token, JWT_SECRET, {
      algorithms: ['HS256'] // Explicitly specify allowed algorithms
    });

    logger.logInfo('JWT token verified successfully', {
      tokenPayload: typeof decoded === 'object' ? { ...decoded, iat: undefined, exp: undefined } : {}
    });

    // Ensure the decoded token is an object (not a string)
    if (typeof decoded === 'string') {
      throw createHttpError(401, 'Invalid token format');
    }

    return decoded as jwt.JwtPayload;
  } catch (error) {
    logger.logError('Failed to verify JWT token', { error });

    if (error instanceof jwt.TokenExpiredError) {
      throw createHttpError(401, 'Token has expired');
    }

    if (error instanceof jwt.JsonWebTokenError) {
      throw createHttpError(401, 'Invalid token');
    }

    // Re-throw other errors
    throw error;
  }
};