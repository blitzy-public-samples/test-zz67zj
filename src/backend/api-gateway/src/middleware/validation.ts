// express v4.18.2
import { Request, Response, NextFunction } from 'express';
import { validateModel } from '../../../shared/utils/validation';
import { createHttpError } from '../../../shared/utils/error';
import logger from '../../../shared/utils/logger';

/**
 * Human Tasks:
 * 1. Configure monitoring alerts for high validation failure rates
 * 2. Set up error tracking for validation errors in production environment
 * 3. Review and adjust validation rules periodically based on business requirements
 * 4. Ensure proper error handling and logging configuration in the API Gateway
 */

/**
 * @description Middleware function to validate the body of incoming API requests against a specified schema.
 * Addresses requirement: Technical Specification/8.3 API Design/8.3.3 Integration Patterns
 * Ensures consistent and reliable validation of incoming API requests.
 * 
 * @param schema - The schema class to validate the request body against
 * @returns A middleware function that validates the request body
 */
export const validateRequest = (schema: any) => {
  return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      // Skip validation if no request body is present and schema is not required
      if (!req.body && !schema) {
        return next();
      }

      // Create an instance of the schema with the request body data
      const modelInstance = Object.assign(new schema(), req.body);

      try {
        // Validate the model instance against the schema
        await validateModel(modelInstance);
        
        // If validation passes, attach the validated model to the request for downstream use
        req.body = modelInstance;
        return next();
      } catch (validationError) {
        // Log validation failure with request details
        logger.logError('Request validation failed', {
          path: req.path,
          method: req.method,
          body: req.body,
          error: validationError,
          schemaName: schema.name,
          requestId: req.headers['x-request-id']
        });

        // Create a validation error response
        const error = createHttpError(400, 'Request validation failed');
        return next(error);
      }
    } catch (error) {
      // Log unexpected errors during validation
      logger.logError('Unexpected error during request validation', {
        path: req.path,
        method: req.method,
        error,
        requestId: req.headers['x-request-id']
      });

      // Create a server error response for unexpected errors
      const serverError = createHttpError(500, 'Internal server error during validation');
      return next(serverError);
    }
  };
};