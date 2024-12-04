/**
 * Human Tasks:
 * 1. Ensure proper environment variables are set for Winston configuration:
 *    - LOG_LEVEL (info, debug, error)
 *    - NODE_ENV (development, production)
 * 2. Configure log storage/shipping solution (e.g., ELK Stack, CloudWatch)
 * 3. Set up log rotation policies if file transport is used
 */

// winston v3.8.2
import winston from 'winston';
import { createHttpError } from './error';

/**
 * @description Configures Winston logger with standardized formatting and transports
 * Addresses requirement: Technical Specification/7.4.1 Monitoring and Observability
 * Ensures structured logging for backend services to improve monitoring and debugging
 */
const winstonLogger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp({
      format: 'YYYY-MM-DD HH:mm:ss'
    }),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: {
    service: 'backend-service',
    environment: process.env.NODE_ENV || 'development'
  },
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.printf(({ timestamp, level, message, ...meta }) => {
          return `${timestamp} ${level}: ${message} ${
            Object.keys(meta).length ? JSON.stringify(meta, null, 2) : ''
          }`;
        })
      )
    })
  ]
});

/**
 * @description Formats metadata for consistent logging structure
 * @param meta - Object containing additional logging metadata
 * @returns Formatted metadata object
 */
const formatMetadata = (meta: Record<string, any> = {}): Record<string, any> => {
  return {
    ...meta,
    timestamp: new Date().toISOString(),
    correlationId: meta.correlationId || undefined,
    requestId: meta.requestId || undefined
  };
};

/**
 * @description Logs informational messages to the logging system
 * Addresses requirement: Technical Specification/7.4.1 Monitoring and Observability
 * @param message - Information message to log
 * @param meta - Additional metadata to include in the log
 */
const logInfo = (message: string, meta: Record<string, any> = {}): void => {
  winstonLogger.info(message, formatMetadata(meta));
};

/**
 * @description Logs error messages to the logging system
 * Addresses requirement: Technical Specification/7.4.1 Monitoring and Observability
 * @param message - Error message to log
 * @param meta - Additional metadata to include in the log
 */
const logError = (message: string, meta: Record<string, any> = {}): void => {
  // If meta contains an error object, extract its properties
  if (meta.error instanceof Error) {
    const error = meta.error;
    meta = {
      ...meta,
      errorName: error.name,
      errorMessage: error.message,
      stackTrace: error.stack,
      // Remove the original error object to prevent circular references
      error: undefined
    };
  }
  
  winstonLogger.error(message, formatMetadata(meta));
};

/**
 * @description Logs debug messages to the logging system
 * Addresses requirement: Technical Specification/7.4.1 Monitoring and Observability
 * @param message - Debug message to log
 * @param meta - Additional metadata to include in the log
 */
const logDebug = (message: string, meta: Record<string, any> = {}): void => {
  winstonLogger.debug(message, formatMetadata(meta));
};

// Export the logger functions
const logger = {
  logInfo,
  logError,
  logDebug
};

export default logger;
export {
  logInfo,
  logError,
  logDebug
};