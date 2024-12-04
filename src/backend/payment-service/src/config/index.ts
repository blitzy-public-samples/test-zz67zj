/**
 * Human Tasks:
 * 1. Create a .env file in the root of the payment-service directory
 * 2. Set up the following required environment variables:
 *    - STRIPE_API_KEY: Your Stripe secret API key
 *    - DATABASE_URL: PostgreSQL connection string
 *    - NODE_ENV: 'development' or 'production'
 *    - PORT: Port number for the payment service
 *    - LOG_LEVEL: Logging level (info, debug, error)
 *    - STRIPE_WEBHOOK_SECRET: Stripe webhook signing secret
 * 3. Ensure proper access controls and encryption for production environment variables
 */

// dotenv v10.0.0
import dotenv from 'dotenv';
import { Payment } from '../../../../shared/models/payment';
import { createHttpError } from '../../../../shared/utils/error';

/**
 * @description Interface defining the structure of configuration settings
 * Addresses requirement: Technical Specification/7.4 Cross-Cutting Concerns/Configuration Management
 */
interface Config {
  port: number;
  nodeEnv: string;
  database: {
    url: string;
  };
  stripe: {
    apiKey: string;
    webhookSecret: string;
  };
  logging: {
    level: string;
  };
  payment: {
    supportedCurrencies: string[];
    minimumAmount: number;
    maximumAmount: number;
  };
}

/**
 * @description Validates that all required environment variables are present
 * Addresses requirement: Technical Specification/7.4 Cross-Cutting Concerns/Configuration Management
 * @throws {Error} If any required environment variable is missing
 */
const validateEnvironmentVariables = (): void => {
  const requiredEnvVars = [
    'STRIPE_API_KEY',
    'DATABASE_URL',
    'NODE_ENV',
    'PORT',
    'LOG_LEVEL',
    'STRIPE_WEBHOOK_SECRET'
  ];

  const missingEnvVars = requiredEnvVars.filter(envVar => !process.env[envVar]);

  if (missingEnvVars.length > 0) {
    throw createHttpError(
      500,
      `Missing required environment variables: ${missingEnvVars.join(', ')}`
    );
  }
};

/**
 * @description Validates payment-specific configuration settings
 * Addresses requirement: Technical Specification/7.4 Cross-Cutting Concerns/Configuration Management
 * @param config - The configuration object to validate
 * @throws {Error} If any payment configuration is invalid
 */
const validatePaymentConfig = (config: Config): void => {
  const { minimumAmount, maximumAmount, supportedCurrencies } = config.payment;

  if (minimumAmount <= 0) {
    throw createHttpError(500, 'Minimum payment amount must be greater than 0');
  }

  if (maximumAmount <= minimumAmount) {
    throw createHttpError(
      500,
      'Maximum payment amount must be greater than minimum amount'
    );
  }

  if (supportedCurrencies.length === 0) {
    throw createHttpError(500, 'At least one supported currency must be specified');
  }
};

/**
 * @description Loads and validates configuration settings from environment variables
 * Addresses requirement: Technical Specification/7.4 Cross-Cutting Concerns/Configuration Management
 * @returns {Config} An object containing all validated configuration settings
 * @throws {Error} If configuration validation fails
 */
export const loadConfig = (): Config => {
  // Load environment variables from .env file
  dotenv.config();

  // Validate environment variables
  validateEnvironmentVariables();

  // Create configuration object
  const config: Config = {
    port: parseInt(process.env.PORT!, 10),
    nodeEnv: process.env.NODE_ENV!,
    database: {
      url: process.env.DATABASE_URL!
    },
    stripe: {
      apiKey: process.env.STRIPE_API_KEY!,
      webhookSecret: process.env.STRIPE_WEBHOOK_SECRET!
    },
    logging: {
      level: process.env.LOG_LEVEL!
    },
    payment: {
      supportedCurrencies: ['USD', 'EUR', 'GBP'], // Default supported currencies
      minimumAmount: 1, // Minimum amount in smallest currency unit (e.g., cents)
      maximumAmount: 999999 // Maximum amount in smallest currency unit
    }
  };

  // Validate payment configuration
  validatePaymentConfig(config);

  return config;
};