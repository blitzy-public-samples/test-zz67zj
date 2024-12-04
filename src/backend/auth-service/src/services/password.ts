/**
 * Human Tasks:
 * 1. Configure bcrypt salt rounds in environment variables (BCRYPT_SALT_ROUNDS)
 * 2. Set up monitoring for password hashing performance metrics
 * 3. Configure alerts for high password verification failure rates
 * 4. Review and adjust password complexity requirements based on security policies
 */

// bcrypt v5.1.0
import bcrypt from 'bcrypt';
import { AuthUser } from '../models/user';
import logger from '../../../shared/utils/logger';
import { validateModel } from '../../../shared/utils/validation';

/**
 * Default number of salt rounds for bcrypt hashing
 * Can be overridden by environment variable BCRYPT_SALT_ROUNDS
 */
const SALT_ROUNDS = process.env.BCRYPT_SALT_ROUNDS ? parseInt(process.env.BCRYPT_SALT_ROUNDS) : 12;

/**
 * Hashes a plain text password using bcrypt.
 * Addresses requirement: Technical Specification/10.1 Authentication and Authorization
 * Ensures secure password storage by using industry-standard hashing algorithm.
 * 
 * @param plainPassword - The plain text password to hash
 * @returns A promise resolving to the hashed password
 */
export async function hashPassword(plainPassword: string): Promise<string> {
    try {
        logger.logInfo('Starting password hashing process', {
            saltRounds: SALT_ROUNDS
        });

        // Generate a salt and hash the password
        const hashedPassword = await bcrypt.hash(plainPassword, SALT_ROUNDS);

        logger.logInfo('Password hashing completed successfully');

        return hashedPassword;
    } catch (error) {
        logger.logError('Error during password hashing', { error });
        throw error;
    }
}

/**
 * Verifies a plain text password against a hashed password.
 * Addresses requirement: Technical Specification/10.1 Authentication and Authorization
 * Ensures secure password verification during authentication.
 * 
 * @param plainPassword - The plain text password to verify
 * @param hashedPassword - The hashed password to compare against
 * @returns A promise resolving to a boolean indicating whether the passwords match
 */
export async function verifyPassword(plainPassword: string, hashedPassword: string): Promise<boolean> {
    try {
        logger.logInfo('Starting password verification process');

        // Compare the plain text password with the hashed password
        const isMatch = await bcrypt.compare(plainPassword, hashedPassword);

        logger.logInfo('Password verification completed', {
            matched: isMatch
        });

        return isMatch;
    } catch (error) {
        logger.logError('Error during password verification', { error });
        throw error;
    }
}