/**
 * Human Tasks:
 * 1. Create a .env file in the api-gateway root directory with required configuration variables:
 *    - PORT: API Gateway port number
 *    - NODE_ENV: Environment (development, production)
 *    - LOG_LEVEL: Logging level (info, debug, error)
 *    - AUTH_SECRET: JWT authentication secret
 *    - RATE_LIMIT_WINDOW: Rate limiting window in minutes
 *    - RATE_LIMIT_MAX_REQUESTS: Maximum requests per window
 * 2. Ensure proper security measures for storing sensitive configuration
 * 3. Review and adjust rate limiting settings based on load testing results
 */

// dotenv v16.0.3
import dotenv from 'dotenv';
import { logError, logInfo } from '../../../shared/utils/logger';
import { validateModel } from '../../../shared/utils/validation';
import { IsNumber, IsString, IsEnum, validateSync } from 'class-validator';

/**
 * @description Configuration schema class with validation rules
 * Addresses requirement: Technical Specification/7.4.3 Security Architecture
 * Ensures secure and consistent configuration management for the API Gateway
 */
class ConfigSchema {
  @IsNumber()
  port: number;

  @IsEnum(['development', 'production', 'test'])
  nodeEnv: string;

  @IsString()
  authSecret: string;

  @IsEnum(['error', 'warn', 'info', 'debug'])
  logLevel: string;

  @IsNumber()
  rateLimitWindow: number;

  @IsNumber()
  rateLimitMaxRequests: number;

  constructor() {
    this.port = parseInt(process.env.PORT || '3000', 10);
    this.nodeEnv = process.env.NODE_ENV || 'development';
    this.authSecret = process.env.AUTH_SECRET || '';
    this.logLevel = process.env.LOG_LEVEL || 'info';
    this.rateLimitWindow = parseInt(process.env.RATE_LIMIT_WINDOW || '15', 10);
    this.rateLimitMaxRequests = parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100', 10);
  }
}

/**
 * @description Loads and validates configuration settings for the API Gateway service
 * Addresses requirement: Technical Specification/7.4.3 Security Architecture
 * @returns Validated configuration object
 * @throws Error if configuration validation fails
 */
export const loadConfig = (): ConfigSchema => {
  try {
    // Load environment variables from .env file
    dotenv.config();

    // Create and validate configuration instance
    const config = new ConfigSchema();
    const validationErrors = validateSync(config);

    if (validationErrors.length > 0) {
      const errorMessages = validationErrors.map(error => 
        `${error.property}: ${Object.values(error.constraints || {}).join(', ')}`
      ).join('; ');
      
      throw new Error(`Configuration validation failed: ${errorMessages}`);
    }

    // Validate required secret values
    if (!config.authSecret) {
      throw new Error('AUTH_SECRET is required but not provided');
    }

    logInfo('API Gateway configuration loaded successfully', {
      nodeEnv: config.nodeEnv,
      logLevel: config.logLevel,
      port: config.port
    });

    return config;
  } catch (error) {
    logError('Failed to load API Gateway configuration', { error });
    throw error;
  }
};