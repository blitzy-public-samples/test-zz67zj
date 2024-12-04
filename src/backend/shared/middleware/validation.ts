// express v4.18.2
import { Request, Response, NextFunction } from 'express';
import { validateModel } from '../utils/validation';
import { createHttpError } from '../utils/error';
import logger from '../utils/logger';

/**
 * Human Tasks:
 * 1. Configure monitoring alerts for high validation failure rates
 * 2. Set up error tracking for validation errors in production environment
 * 3. Review and adjust validation rules periodically based on business requirements
 * 4. Ensure proper error handling and logging configuration in the production environment
 */

/**
 * @description Middleware function to validate incoming HTTP requests based on a provided schema.
 * Addresses requirement: Technical Specification/8.3 API Design/8.3.3 Integration Patterns
 * Ensures consistent and reliable validation of incoming requests and data models.
 * 
 * @param schema - The validation schema to validate the request against
 * @returns An Express middleware function for validating requests
 */
export const validateRequest = (schema: any) => {
  return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      // Create a combined object of request data to validate
      const dataToValidate = {
        ...req.body,
        ...req.query,
        ...req.params
      };

      // Create an instance of the schema with the request data
      const modelInstance = Object.assign(new schema(), dataToValidate);

      try {
        // Validate the model instance using the validateModel utility
        await validateModel(modelInstance);

        // If validation passes, proceed to the next middleware
        next();
      } catch (validationError) {
        // Log validation failure with request details
        logger.logError('Request validation failed', {
          path: req.path,
          method: req.method,
          schema: schema.name,
          requestId: req.headers['x-request-id'],
          error: validationError,
          requestData: {
            body: req.body,
            query: req.query,
            params: req.params
          }
        });

        // Create and throw an HTTP error for invalid request data
        throw createHttpError(400, 'Invalid request data');
      }
    } catch (error) {
      // Log any unexpected errors during validation
      logger.logError('Unexpected error during request validation', {
        path: req.path,
        method: req.method,
        schema: schema.name,
        requestId: req.headers['x-request-id'],
        error
      });

      // Pass the error to Express error handler
      next(error);
    }
  };
};
```

The implementation follows the provided JSON specification and integrates with the imported utilities. Here's a breakdown of the key aspects:

1. The middleware uses relative imports for all internal dependencies as specified.
2. It correctly uses the imported functions and objects according to their signatures and purposes.
3. The implementation addresses the "Data Validation" requirement from the technical specification.
4. The middleware function follows the Express middleware pattern, taking request, response, and next function parameters.
5. It includes comprehensive error handling and logging using the provided logger utility.
6. The code includes necessary type annotations and follows TypeScript best practices.
7. The implementation validates request data against provided schemas using the validateModel utility.
8. It includes helpful comments and human tasks that need attention.

The middleware can be used to validate incoming requests by providing a validation schema:

```typescript
// Example usage:
app.post('/api/users', validateRequest(UserSchema), createUser);