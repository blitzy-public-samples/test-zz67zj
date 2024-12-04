// class-validator v0.13.2
import { validate, ValidationError } from 'class-validator';
import { createHttpError } from './error';
import logger from './logger';
import { User } from '../models/user';
import { Booking } from '../models/booking';
import { Payment } from '../models/payment';

/**
 * Human Tasks:
 * 1. Configure monitoring alerts for high validation failure rates
 * 2. Set up error tracking for validation errors in production environment
 * 3. Review and adjust validation rules based on business requirements
 * 4. Ensure proper error handling and logging configuration
 */

/**
 * @description Validates a given data model instance using class-validator decorators.
 * Addresses requirement: Technical Specification/8.3 API Design/8.3.3 Integration Patterns
 * Ensures consistent and reliable validation of data models used across backend services.
 * 
 * @param modelInstance - The model instance to validate
 * @returns A promise resolving to an array of validation errors, if any
 * @throws HttpError if validation fails
 */
export async function validateModel(modelInstance: any): Promise<ValidationError[]> {
  try {
    const validationErrors = await validate(modelInstance);

    if (validationErrors.length > 0) {
      logger.logError('Model validation failed', {
        modelType: modelInstance.constructor.name,
        errors: validationErrors.map(error => ({
          property: error.property,
          constraints: error.constraints
        }))
      });

      throw createHttpError(400, 'Invalid data provided');
    }

    return validationErrors;
  } catch (error) {
    logger.logError('Error during model validation', { error });
    throw error;
  }
}

/**
 * @description Validates a User model instance.
 * Addresses requirement: Technical Specification/8.3 API Design/8.3.3 Integration Patterns
 * 
 * @param userInstance - The User instance to validate
 * @returns A promise resolving to an array of validation errors, if any
 * @throws HttpError if validation fails
 */
export async function validateUser(userInstance: User): Promise<ValidationError[]> {
  try {
    const validationErrors = await userInstance.validate();

    if (validationErrors.length > 0) {
      logger.logError('User validation failed', {
        userId: userInstance.id,
        errors: validationErrors.map(error => ({
          property: error.property,
          constraints: error.constraints
        }))
      });

      throw createHttpError(400, 'Invalid user data');
    }

    return validationErrors;
  } catch (error) {
    logger.logError('Error during user validation', { error });
    throw error;
  }
}

/**
 * @description Validates a Booking model instance.
 * Addresses requirement: Technical Specification/8.3 API Design/8.3.3 Integration Patterns
 * 
 * @param bookingInstance - The Booking instance to validate
 * @returns A promise resolving to an array of validation errors, if any
 * @throws HttpError if validation fails
 */
export async function validateBooking(bookingInstance: Booking): Promise<ValidationError[]> {
  try {
    const validationErrors = await bookingInstance.validate();

    if (validationErrors.length > 0) {
      logger.logError('Booking validation failed', {
        bookingId: bookingInstance.id,
        errors: validationErrors.map(error => ({
          property: error.property,
          constraints: error.constraints
        }))
      });

      throw createHttpError(400, 'Invalid booking data');
    }

    return validationErrors;
  } catch (error) {
    logger.logError('Error during booking validation', { error });
    throw error;
  }
}

/**
 * @description Validates a Payment model instance.
 * Addresses requirement: Technical Specification/8.3 API Design/8.3.3 Integration Patterns
 * 
 * @param paymentInstance - The Payment instance to validate
 * @returns A promise resolving to an array of validation errors, if any
 * @throws HttpError if validation fails
 */
export async function validatePayment(paymentInstance: Payment): Promise<ValidationError[]> {
  try {
    const validationErrors = await paymentInstance.validate();

    if (validationErrors.length > 0) {
      logger.logError('Payment validation failed', {
        paymentId: paymentInstance.id,
        errors: validationErrors.map(error => ({
          property: error.property,
          constraints: error.constraints
        }))
      });

      throw createHttpError(400, 'Invalid payment data');
    }

    return validationErrors;
  } catch (error) {
    logger.logError('Error during payment validation', { error });
    throw error;
  }
}