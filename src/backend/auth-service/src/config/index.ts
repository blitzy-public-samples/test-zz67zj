/**
 * Human Tasks:
 * 1. Set up environment variables in .env file:
 *    - PORT (default: 3000)
 *    - JWT_SECRET (required, no default)
 *    - DB_CONNECTION_STRING (required, no default)
 *    - LOG_LEVEL (default: 'info')
 * 2. Ensure proper security measures for storing sensitive environment variables
 * 3. Configure monitoring for configuration-related errors
 * 4. Review and adjust configuration values based on deployment environment
 */

// dotenv ^16.0.0
import dotenv from 'dotenv';
import { logInfo, logError, logDebug } from '../../../shared/utils/logger';
import { validateModel } from '../../../shared/utils/validation';
import { AuthUser } from '../models/user';
import { generateToken } from '../services/jwt';
import { hashPassword } from '../services/password';

/**
 * @description Loads and validates environment variables for the authentication service
 * Addresses requirement: Technical Specification/10.1 Authentication and Authorization
 * Ensures secure and consistent configuration management
 */
const loadConfig = (): Record<string, any> => {
  try {
    // Load environment variables from .env file
    const result = dotenv.config();

    if (result.error) {
      logError('Failed to load .env file', { error: result.error });
      throw new Error('Environment configuration failed');
    }

    // Define required configuration with defaults
    const config = {
      PORT: parseInt(process.env.PORT || '3000', 10),
      JWT_SECRET: process.env.JWT_SECRET,
      DB_CONNECTION_STRING: process.env.DB_CONNECTION_STRING,
      LOG_LEVEL: process.env.LOG_LEVEL || 'info'
    };

    // Validate required configuration values
    if (!config.JWT_SECRET) {
      throw new Error('JWT_SECRET is required but not provided');
    }

    if (!config.DB_CONNECTION_STRING) {
      throw new Error('DB_CONNECTION_STRING is required but not provided');
    }

    // Validate configuration values
    if (isNaN(config.PORT) || config.PORT <= 0) {
      throw new Error('Invalid PORT configuration');
    }

    const validLogLevels = ['error', 'warn', 'info', 'debug'];
    if (!validLogLevels.includes(config.LOG_LEVEL.toLowerCase())) {
      throw new Error('Invalid LOG_LEVEL configuration');
    }

    logInfo('Configuration loaded successfully', {
      port: config.PORT,
      logLevel: config.LOG_LEVEL,
      // Avoid logging sensitive values like JWT_SECRET and DB_CONNECTION_STRING
    });

    return config;
  } catch (error) {
    logError('Configuration loading failed', { error });
    throw error;
  }
};

// Load configuration immediately and export it
const config = loadConfig();

// Export configuration object as default
export default config;

// Export individual configuration values
export const {
  PORT,
  JWT_SECRET,
  DB_CONNECTION_STRING,
  LOG_LEVEL
} = config;