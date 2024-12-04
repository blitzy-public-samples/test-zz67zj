// express v4.18.2
import { Router } from 'express';
import { Location } from '../../../shared/models/location';
import { Location as TrackingProto } from '../../../shared/proto/tracking.proto';
import logger from '../../../shared/utils/logger';
import { validateModel } from '../../../shared/utils/validation';
import { authenticateRequest } from '../middleware/auth';
import { validateRequest } from '../middleware/validation';

/**
 * Human Tasks:
 * 1. Configure rate limiting for location update endpoints
 * 2. Set up monitoring for tracking service availability
 * 3. Configure alerts for high error rates in location updates
 * 4. Review and adjust validation rules for location data
 */

/**
 * @description Registers tracking-related API routes to the Express application.
 * Addresses requirement: Technical Specification/7.2.1 Core Components/Tracking Service
 * Handles real-time location processing for tracking dog walks.
 * 
 * @param app - Express Router instance
 */
export const registerTrackingRoutes = (app: Router): void => {
  // Create a new router for tracking routes
  const trackingRouter = Router();

  /**
   * POST /tracking/location
   * Updates the real-time location for a dog walk tracking session
   * Addresses requirement: Technical Specification/7.2.1 Core Components/Tracking Service
   */
  trackingRouter.post(
    '/location',
    authenticateRequest,
    validateRequest(Location),
    async (req, res, next) => {
      try {
        // Log the incoming location update request
        logger.logInfo('Received location update request', {
          userId: req.user?.id,
          location: req.body,
          requestId: req.headers['x-request-id']
        });

        // Validate the location data using the shared model
        const location = new Location(
          req.body.latitude,
          req.body.longitude,
          req.body.address
        );
        await validateModel(location);

        // Convert to protobuf message for downstream processing
        const protoLocation: TrackingProto = {
          latitude: location.latitude,
          longitude: location.longitude,
          address: location.address
        };

        // Log successful location update
        logger.logInfo('Location update processed successfully', {
          userId: req.user?.id,
          location: protoLocation,
          requestId: req.headers['x-request-id']
        });

        // Send success response
        res.status(200).json({
          success: true,
          message: 'Location updated successfully',
          data: location
        });
      } catch (error) {
        // Log error during location update
        logger.logError('Error processing location update', {
          error,
          userId: req.user?.id,
          requestId: req.headers['x-request-id']
        });
        next(error);
      }
    }
  );

  // Mount the tracking routes under /tracking
  app.use('/tracking', trackingRouter);
};