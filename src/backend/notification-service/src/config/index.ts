// @ts-check

/**
 * Configuration module for the Notification Service
 * Version: 1.0.0
 * 
 * Human Tasks:
 * 1. Create a .env file in the root directory of the notification-service
 * 2. Set up the following environment variables in the .env file:
 *    - NOTIFICATION_SERVICE_PORT=3000
 *    - NOTIFICATION_SERVICE_HOST=localhost
 *    - FCM_API_KEY=your_firebase_cloud_messaging_api_key
 *    - APNS_KEY_ID=your_apple_push_notification_key_id
 *    - APNS_TEAM_ID=your_apple_developer_team_id
 *    - APNS_KEY_PATH=path_to_your_p8_file
 *    - APNS_BUNDLE_ID=your_ios_app_bundle_id
 *    - EMAIL_SMTP_HOST=your_smtp_host
 *    - EMAIL_SMTP_PORT=587
 *    - EMAIL_SMTP_USER=your_smtp_username
 *    - EMAIL_SMTP_PASS=your_smtp_password
 *    - EMAIL_FROM_ADDRESS=noreply@dogwalker.com
 *    - REDIS_HOST=localhost
 *    - REDIS_PORT=6379
 *    - REDIS_PASSWORD=your_redis_password
 * 3. Ensure proper permissions are set for the .env file
 */

// Third-party imports
import dotenv from 'dotenv'; // ^16.0.3

// Load environment variables from .env file
dotenv.config();

/**
 * Interface defining the structure of the notification service configuration
 */
interface NotificationConfig {
  server: {
    port: number;
    host: string;
  };
  firebase: {
    apiKey: string;
  };
  apns: {
    keyId: string;
    teamId: string;
    keyPath: string;
    bundleId: string;
  };
  email: {
    smtp: {
      host: string;
      port: number;
      user: string;
      pass: string;
    };
    fromAddress: string;
  };
  redis: {
    host: string;
    port: number;
    password: string;
  };
}

/**
 * Validates that all required environment variables are present
 * @throws {Error} If any required environment variable is missing
 */
const validateEnvironmentVariables = (): void => {
  const requiredVariables = [
    'NOTIFICATION_SERVICE_PORT',
    'NOTIFICATION_SERVICE_HOST',
    'FCM_API_KEY',
    'APNS_KEY_ID',
    'APNS_TEAM_ID',
    'APNS_KEY_PATH',
    'APNS_BUNDLE_ID',
    'EMAIL_SMTP_HOST',
    'EMAIL_SMTP_PORT',
    'EMAIL_SMTP_USER',
    'EMAIL_SMTP_PASS',
    'EMAIL_FROM_ADDRESS',
    'REDIS_HOST',
    'REDIS_PORT',
    'REDIS_PASSWORD'
  ];

  const missingVariables = requiredVariables.filter(variable => !process.env[variable]);

  if (missingVariables.length > 0) {
    throw new Error(`Missing required environment variables: ${missingVariables.join(', ')}`);
  }
};

/**
 * Loads and validates the configuration settings for the Notification Service
 * Requirement addressed: Configuration Management (7.2.1 Core Components/Notification Service)
 * @returns {NotificationConfig} The validated configuration object
 * @throws {Error} If configuration validation fails
 */
export const loadConfig = (): NotificationConfig => {
  // Validate environment variables
  validateEnvironmentVariables();

  // Create and return the configuration object
  const config: NotificationConfig = {
    server: {
      port: parseInt(process.env.NOTIFICATION_SERVICE_PORT!, 10),
      host: process.env.NOTIFICATION_SERVICE_HOST!
    },
    firebase: {
      apiKey: process.env.FCM_API_KEY!
    },
    apns: {
      keyId: process.env.APNS_KEY_ID!,
      teamId: process.env.APNS_TEAM_ID!,
      keyPath: process.env.APNS_KEY_PATH!,
      bundleId: process.env.APNS_BUNDLE_ID!
    },
    email: {
      smtp: {
        host: process.env.EMAIL_SMTP_HOST!,
        port: parseInt(process.env.EMAIL_SMTP_PORT!, 10),
        user: process.env.EMAIL_SMTP_USER!,
        pass: process.env.EMAIL_SMTP_PASS!
      },
      fromAddress: process.env.EMAIL_FROM_ADDRESS!
    },
    redis: {
      host: process.env.REDIS_HOST!,
      port: parseInt(process.env.REDIS_PORT!, 10),
      password: process.env.REDIS_PASSWORD!
    }
  };

  // Validate configuration values
  if (isNaN(config.server.port) || config.server.port <= 0) {
    throw new Error('Invalid NOTIFICATION_SERVICE_PORT value');
  }

  if (isNaN(config.email.smtp.port) || config.email.smtp.port <= 0) {
    throw new Error('Invalid EMAIL_SMTP_PORT value');
  }

  if (isNaN(config.redis.port) || config.redis.port <= 0) {
    throw new Error('Invalid REDIS_PORT value');
  }

  // Validate email format
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(config.email.fromAddress)) {
    throw new Error('Invalid EMAIL_FROM_ADDRESS format');
  }

  return config;
};

// Export the configuration object as a global
export const config = loadConfig();