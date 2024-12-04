/**
 * Human Tasks:
 * 1. Configure monitoring alerts for high booking failure rates
 * 2. Set up error tracking for booking-related errors in production
 * 3. Review and adjust request validation rules based on business requirements
 * 4. Ensure proper error handling and logging configuration in the API Gateway
 * 5. Set up rate limiting for booking creation endpoints
 */

// express v4.18.2
import { Request, Response, NextFunction, Router } from 'express';
import { Booking, validate } from '../../../shared/models/booking';
import { createHttpError } from '../../../shared/utils/error';
import logger from '../../../shared/utils/logger';
import { validateRequest } from '../middleware/validation';
import { authenticateRequest } from '../middleware/auth';

/**
 * @description Handles the creation of a new booking via the API.
 * Addresses requirement: Technical Specification/1.3 Scope/Core Features/Booking System
 * Handles real-time availability search, booking management, and schedule coordination.
 */
export const createBookingRoute = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    // Log the incoming booking request
    logger.logInfo('Creating new booking', {
      userId: req.user?.id,
      requestBody: req.body,
      path: req.path,
      method: req.method
    });

    // Create and validate the booking instance
    const booking = new Booking(
      req.body.id,
      req.body.user,
      req.body.location,
      req.body.payment,
      new Date(req.body.scheduledAt),
      req.body.status || 'pending'
    );

    // Validate the booking data
    await validate(booking);

    // Call the Booking Service to create the booking
    try {
      await CreateBookingService(booking);

      // Send successful response
      res.status(201).json({
        success: true,
        data: booking
      });

      logger.logInfo('Booking created successfully', {
        bookingId: booking.id,
        userId: req.user?.id
      });
    } catch (error) {
      logger.logError('Failed to create booking in Booking Service', {
        error,
        bookingData: booking,
        userId: req.user?.id
      });
      throw createHttpError(500, 'Failed to create booking');
    }
  } catch (error) {
    logger.logError('Error in create booking route', {
      error,
      path: req.path,
      method: req.method,
      userId: req.user?.id
    });
    next(error);
  }
};

/**
 * @description Handles retrieving a booking by its ID via the API.
 * Addresses requirement: Technical Specification/1.3 Scope/Core Features/Booking System
 * Handles booking management and retrieval.
 */
export const getBookingRoute = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const bookingId = req.params.id;

    // Log the booking retrieval request
    logger.logInfo('Retrieving booking', {
      bookingId,
      userId: req.user?.id,
      path: req.path,
      method: req.method
    });

    if (!bookingId) {
      throw createHttpError(400, 'Booking ID is required');
    }

    // Call the Booking Service to retrieve the booking
    try {
      const booking = await GetBookingService(bookingId);

      if (!booking) {
        throw createHttpError(404, 'Booking not found');
      }

      // Send successful response
      res.status(200).json({
        success: true,
        data: booking
      });

      logger.logInfo('Booking retrieved successfully', {
        bookingId,
        userId: req.user?.id
      });
    } catch (error) {
      logger.logError('Failed to retrieve booking from Booking Service', {
        error,
        bookingId,
        userId: req.user?.id
      });
      throw createHttpError(500, 'Failed to retrieve booking');
    }
  } catch (error) {
    logger.logError('Error in get booking route', {
      error,
      path: req.path,
      method: req.method,
      userId: req.user?.id
    });
    next(error);
  }
};

// Create router instance
const router = Router();

// Register routes with middleware
router.post(
  '/bookings',
  authenticateRequest,
  validateRequest(Booking),
  createBookingRoute
);

router.get(
  '/bookings/:id',
  authenticateRequest,
  getBookingRoute
);

export default router;