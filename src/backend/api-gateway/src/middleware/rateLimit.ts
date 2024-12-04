/**
 * Human Tasks:
 * 1. Monitor rate limiting metrics in production environment
 * 2. Set up alerts for high rate of limit violations
 * 3. Configure appropriate error tracking for rate limit events
 * 4. Review and adjust rate limits based on actual usage patterns
 */

// express-rate-limit v6.7.0
import rateLimit, { Options } from 'express-rate-limit';
import { createHttpError } from '../../../shared/utils/error';
import logger from '../../../shared/utils/logger';
import { validateModel } from '../../../shared/utils/validation';
import { loadConfig } from '../config';
import { IsNumber, IsBoolean, validateSync } from 'class-validator';

/**
 * @description Rate limiting configuration schema with validation rules
 * Addresses requirement: Technical Specification/8.3 API Design/8.3.3 Integration Patterns
 */
class RateLimitConfig {
  @IsNumber()
  windowMs: number;

  @IsNumber()
  max: number;

  @IsBoolean()
  standardHeaders: boolean;

  @IsBoolean()
  legacyHeaders: boolean;

  constructor(windowMs: number, max: number) {
    this.windowMs = windowMs * 60 * 1000; // Convert minutes to milliseconds
    this.max = max;
    this.standardHeaders = true;
    this.legacyHeaders = false;
  }
}

/**
 * @description Middleware function to enforce rate limiting on API requests
 * Addresses requirement: Technical Specification/8.3 API Design/8.3.3 Integration Patterns
 * Implements rate limiting to control the number of requests a client can make within a specific time window
 * 
 * @param options - Optional configuration options for rate limiting
 * @returns Express middleware function for rate limiting
 */
export const rateLimitMiddleware = (options?: Partial<Options>) => {
  try {
    // Load configuration settings
    const config = loadConfig();
    
    // Create and validate rate limit configuration
    const rateLimitConfig = new RateLimitConfig(
      config.rateLimitWindow,
      config.rateLimitMaxRequests
    );
    
    const validationErrors = validateSync(rateLimitConfig);
    if (validationErrors.length > 0) {
      throw createHttpError(500, 'Invalid rate limit configuration');
    }

    // Create rate limiter instance with merged configuration
    const limiter = rateLimit({
      windowMs: rateLimitConfig.windowMs,
      max: rateLimitConfig.max,
      standardHeaders: rateLimitConfig.standardHeaders,
      legacyHeaders: rateLimitConfig.legacyHeaders,
      handler: (req, res) => {
        const error = createHttpError(429, 'Too many requests, please try again later');
        logger.logError('Rate limit exceeded', {
          ip: req.ip,
          path: req.path,
          headers: req.headers,
        });
        res.status(429).json({
          success: false,
          error: {
            code: 429,
            message: error.message
          }
        });
      },
      skip: (req) => {
        // Skip rate limiting for health check endpoints
        return req.path === '/health' || req.path === '/metrics';
      },
      ...options // Allow overriding default options
    });

    logger.logInfo('Rate limiting middleware initialized', {
      windowMs: rateLimitConfig.windowMs,
      maxRequests: rateLimitConfig.max,
      standardHeaders: rateLimitConfig.standardHeaders
    });

    return limiter;
  } catch (error) {
    logger.logError('Failed to initialize rate limiting middleware', { error });
    throw error;
  }
};