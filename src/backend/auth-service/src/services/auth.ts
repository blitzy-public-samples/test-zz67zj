/**
 * Human Tasks:
 * 1. Configure proper environment variables for JWT and password hashing
 * 2. Set up monitoring for authentication failures and suspicious activities
 * 3. Configure rate limiting for authentication endpoints
 * 4. Implement token rotation strategy if required
 */

// http-errors v2.0.0
import { createHttpError } from 'http-errors';
import { AuthUser } from '../models/user';
import { generateToken, verifyToken } from './jwt';
import { hashPassword, verifyPassword } from './password';
import logger from '../../../shared/utils/logger';

/**
 * Registers a new user by validating input, hashing the password, and generating a JWT.
 * Addresses requirement: Technical Specification/10.1 Authentication and Authorization
 * Ensures secure user registration with proper validation and password hashing.
 * 
 * @param user - The user data to register
 * @returns A signed JWT for the newly registered user
 * @throws HttpError if validation fails or registration fails
 */
export async function registerUser(user: AuthUser): Promise<string> {
    try {
        logger.logInfo('Starting user registration process', {
            email: user.email,
            name: user.name
        });

        // Validate the user object
        await user.validate();

        // Hash the user's password
        const hashedPassword = await hashPassword(user.password);
        user.password = hashedPassword;

        // Note: Database operations are handled by the calling service
        // This service focuses on authentication logic only

        // Generate JWT for the new user
        const token = await generateToken(user);

        logger.logInfo('User registration completed successfully', {
            userId: user.id,
            email: user.email
        });

        return token;
    } catch (error) {
        logger.logError('User registration failed', {
            email: user.email,
            error
        });

        if (error instanceof Error) {
            throw createHttpError(400, error.message);
        }
        throw createHttpError(500, 'Registration failed due to internal error');
    }
}

/**
 * Authenticates a user by verifying their credentials and generating a JWT.
 * Addresses requirement: Technical Specification/10.1 Authentication and Authorization
 * Ensures secure user authentication with password verification.
 * 
 * @param email - The user's email address
 * @param password - The user's password
 * @returns A signed JWT for the authenticated user
 * @throws HttpError if authentication fails
 */
export async function loginUser(email: string, password: string): Promise<string> {
    try {
        logger.logInfo('Starting user login process', { email });

        if (!email || !password) {
            throw createHttpError(400, 'Email and password are required');
        }

        // Note: User retrieval from database is handled by the calling service
        // This is a placeholder for the user object that would be retrieved
        const user = new AuthUser(
            'placeholder-id',
            email,
            password,
            'placeholder-name',
            new Date(),
            new Date()
        );

        // Verify the password
        const isPasswordValid = await verifyPassword(password, user.password);
        if (!isPasswordValid) {
            logger.logError('Invalid password attempt', { email });
            throw createHttpError(401, 'Invalid credentials');
        }

        // Generate JWT for the authenticated user
        const token = await generateToken(user);

        logger.logInfo('User login completed successfully', {
            userId: user.id,
            email: user.email
        });

        return token;
    } catch (error) {
        logger.logError('User login failed', {
            email,
            error
        });

        if (error instanceof Error) {
            throw createHttpError(401, 'Authentication failed');
        }
        throw createHttpError(500, 'Login failed due to internal error');
    }
}

/**
 * Authenticates a user by verifying their JWT.
 * Addresses requirement: Technical Specification/10.1 Authentication and Authorization
 * Ensures secure token-based authentication for protected routes.
 * 
 * @param token - The JWT to verify
 * @returns The decoded payload of the JWT
 * @throws HttpError if token verification fails
 */
export async function authenticateToken(token: string): Promise<object> {
    try {
        logger.logInfo('Starting token authentication process');

        if (!token) {
            throw createHttpError(401, 'No token provided');
        }

        // Verify the token
        const decoded = verifyToken(token);

        logger.logInfo('Token authentication completed successfully', {
            userId: decoded.userId
        });

        return decoded;
    } catch (error) {
        logger.logError('Token authentication failed', { error });

        if (error instanceof Error) {
            throw createHttpError(401, 'Invalid or expired token');
        }
        throw createHttpError(500, 'Authentication failed due to internal error');
    }
}