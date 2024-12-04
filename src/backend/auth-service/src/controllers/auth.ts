/**
 * Human Tasks:
 * 1. Configure rate limiting for authentication endpoints
 * 2. Set up monitoring for authentication failures
 * 3. Configure CORS settings for authentication endpoints
 * 4. Review and adjust error handling strategies based on security policies
 */

// http-errors v2.0.0
import { createHttpError } from 'http-errors';
import { Request, Response } from 'express';

// Internal imports with relative paths
import { AuthUser } from '../models/user';
import { generateToken, verifyToken } from '../services/jwt';
import { hashPassword, verifyPassword } from '../services/password';
import { registerUser, loginUser, authenticateToken } from '../services/auth';
import logger from '../../../shared/utils/logger';

/**
 * Handles user registration requests.
 * Addresses requirement: Technical Specification/10.1 Authentication and Authorization
 * Implements secure user registration with input validation and password hashing.
 * 
 * @param req - Express request object containing user registration data
 * @param res - Express response object
 */
export async function register(req: Request, res: Response): Promise<void> {
    try {
        logger.logInfo('Processing registration request', {
            email: req.body.email
        });

        // Extract user data from request body
        const { email, password, name } = req.body;

        // Create new user instance
        const user = new AuthUser(
            crypto.randomUUID(), // Generate unique ID
            email,
            password,
            name,
            new Date(),
            new Date()
        );

        // Register user and get JWT
        const token = await registerUser(user);

        logger.logInfo('Registration successful', {
            userId: user.id,
            email: user.email
        });

        // Send success response with JWT
        res.status(201).json({
            success: true,
            data: {
                token,
                user: {
                    id: user.id,
                    email: user.email,
                    name: user.name
                }
            }
        });
    } catch (error) {
        logger.logError('Registration failed', { error });

        if (error instanceof Error) {
            const statusCode = error.name === 'ValidationError' ? 400 : 500;
            res.status(statusCode).json({
                success: false,
                error: {
                    message: error.message
                }
            });
        } else {
            res.status(500).json({
                success: false,
                error: {
                    message: 'Internal server error during registration'
                }
            });
        }
    }
}

/**
 * Handles user login requests.
 * Addresses requirement: Technical Specification/10.1 Authentication and Authorization
 * Implements secure user authentication with credential verification.
 * 
 * @param req - Express request object containing login credentials
 * @param res - Express response object
 */
export async function login(req: Request, res: Response): Promise<void> {
    try {
        logger.logInfo('Processing login request', {
            email: req.body.email
        });

        // Extract credentials from request body
        const { email, password } = req.body;

        // Validate required fields
        if (!email || !password) {
            throw createHttpError(400, 'Email and password are required');
        }

        // Authenticate user and get JWT
        const token = await loginUser(email, password);

        logger.logInfo('Login successful', { email });

        // Send success response with JWT
        res.status(200).json({
            success: true,
            data: {
                token
            }
        });
    } catch (error) {
        logger.logError('Login failed', {
            email: req.body.email,
            error
        });

        if (error instanceof Error) {
            const statusCode = error.name === 'UnauthorizedError' ? 401 : 500;
            res.status(statusCode).json({
                success: false,
                error: {
                    message: error.message
                }
            });
        } else {
            res.status(500).json({
                success: false,
                error: {
                    message: 'Internal server error during login'
                }
            });
        }
    }
}

/**
 * Handles session verification requests.
 * Addresses requirement: Technical Specification/10.1 Authentication and Authorization
 * Implements secure token verification for protected routes.
 * 
 * @param req - Express request object containing JWT in headers
 * @param res - Express response object
 */
export async function verify(req: Request, res: Response): Promise<void> {
    try {
        logger.logInfo('Processing token verification request');

        // Extract token from Authorization header
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            throw createHttpError(401, 'No token provided');
        }

        const token = authHeader.split(' ')[1];

        // Verify token and get decoded payload
        const decoded = await authenticateToken(token);

        logger.logInfo('Token verification successful', {
            userId: decoded.userId
        });

        // Send success response with decoded payload
        res.status(200).json({
            success: true,
            data: {
                user: decoded
            }
        });
    } catch (error) {
        logger.logError('Token verification failed', { error });

        if (error instanceof Error) {
            const statusCode = error.name === 'UnauthorizedError' ? 401 : 500;
            res.status(statusCode).json({
                success: false,
                error: {
                    message: error.message
                }
            });
        } else {
            res.status(500).json({
                success: false,
                error: {
                    message: 'Internal server error during token verification'
                }
            });
        }
    }
}