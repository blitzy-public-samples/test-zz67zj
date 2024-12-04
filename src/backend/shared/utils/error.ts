// http-errors v2.0.0
import createError from 'http-errors';
import { Response } from 'express';

/**
 * @description Creates a standardized HTTP error object with a status code and message.
 * Addresses requirement: Technical Specification/8.3 API Design/8.3.3 Integration Patterns
 * Ensures consistent error handling and response formatting across backend services.
 * 
 * @param statusCode - HTTP status code for the error
 * @param message - Descriptive message explaining the error
 * @returns An HTTP error object with the specified status code and message
 */
export const createHttpError = (statusCode: number, message: string) => {
  // Use http-errors library to create a standardized error object
  return createError(statusCode, message);
};

/**
 * @description Handles errors by formatting a response object consistently.
 * Addresses requirement: Technical Specification/8.3 API Design/8.3.3 Integration Patterns
 * Ensures consistent error handling and response formatting across backend services.
 * 
 * @param error - Error object to be handled
 * @param response - Express response object to send the error
 */
export const handleError = (error: Error, response: Response): void => {
  // Default error values for internal server errors
  let statusCode = 500;
  let errorMessage = 'Internal Server Error';
  let errorDetails = {};

  // Check if the error is an HTTP error (created by http-errors)
  if (createError.isHttpError(error)) {
    statusCode = error.status;
    errorMessage = error.message;
    // Include any additional properties from the error object
    errorDetails = {
      ...error,
      // Exclude internal error properties
      status: undefined,
      statusCode: undefined,
      message: undefined,
      stack: undefined
    };
  }

  // Format the error response consistently
  const errorResponse = {
    success: false,
    error: {
      code: statusCode,
      message: errorMessage,
      ...(Object.keys(errorDetails).length > 0 && { details: errorDetails }),
      // Include stack trace in development environment only
      ...(process.env.NODE_ENV === 'development' && { stack: error.stack })
    }
  };

  // Send the formatted error response
  response.status(statusCode).json(errorResponse);
};