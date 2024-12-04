/**
 * Human Tasks:
 * 1. Ensure proper environment variables are set for logging configuration:
 *    - LOG_LEVEL (info, debug, error)
 *    - NODE_ENV (development, production)
 * 2. Configure log storage/shipping solution (e.g., ELK Stack, CloudWatch)
 * 3. Set up log rotation policies if file transport is used
 */

// express v4.18.2
import { Request, Response, NextFunction } from 'express';
import { logInfo, logError } from '../utils/logger';
import { createHttpError } from '../utils/error';

/**
 * @description Middleware for logging HTTP requests and responses in backend services.
 * Addresses requirement: Technical Specification/7.4.1 Monitoring and Observability
 * Ensures structured logging for HTTP requests and responses to improve monitoring and debugging.
 * 
 * @param req - Express request object
 * @param res - Express response object
 * @param next - Express next function
 */
export const loggingMiddleware = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const startTime = Date.now();
  const requestId = req.headers['x-request-id'] || crypto.randomUUID();

  // Log the incoming request
  logInfo('Incoming HTTP Request', {
    requestId,
    method: req.method,
    url: req.originalUrl,
    headers: {
      ...req.headers,
      // Exclude sensitive headers
      authorization: req.headers.authorization ? '[REDACTED]' : undefined,
      cookie: req.headers.cookie ? '[REDACTED]' : undefined
    },
    query: req.query,
    // Only log body for non-GET requests and exclude sensitive data
    ...(req.method !== 'GET' && {
      body: {
        ...req.body,
        password: req.body?.password ? '[REDACTED]' : undefined,
        token: req.body?.token ? '[REDACTED]' : undefined
      }
    }),
    ip: req.ip,
    userAgent: req.get('user-agent')
  });

  // Capture the original res.end to hook into the response
  const originalEnd = res.end;
  let responseBody: any;

  // Override res.end to capture response data
  res.end = function(chunk: any, ...rest: any[]): any {
    if (chunk) {
      responseBody = chunk.toString();
      try {
        responseBody = JSON.parse(responseBody);
      } catch {
        // If response is not JSON, keep it as string
      }
    }
    
    const responseTime = Date.now() - startTime;
    const statusCode = res.statusCode;

    // Log the response
    const logMethod = statusCode >= 400 ? logError : logInfo;
    logMethod('HTTP Response Completed', {
      requestId,
      method: req.method,
      url: req.originalUrl,
      statusCode,
      responseTime,
      responseHeaders: res.getHeaders(),
      responseBody: statusCode >= 400 ? responseBody : undefined, // Only log response body for errors
      ip: req.ip,
      userAgent: req.get('user-agent')
    });

    // Call original end method
    return originalEnd.call(res, chunk, ...rest);
  };

  // Error handling
  try {
    next();
  } catch (error) {
    const httpError = createHttpError(500, 'Internal Server Error occurred during request processing');
    logError('Error in logging middleware', {
      requestId,
      error,
      method: req.method,
      url: req.originalUrl
    });
    next(httpError);
  }
};