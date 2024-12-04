/**
 * Human Tasks:
 * 1. Configure rate limiting for API endpoints
 * 2. Set up monitoring for API Gateway performance
 * 3. Configure CORS settings for API endpoints
 * 4. Review and adjust error handling strategies
 * 5. Ensure proper logging configuration
 */

// express v4.18.2
import { Router } from 'express';
import { setupAuthRoutes } from './auth';
import { createBookingRoute, getBookingRoute } from './booking';
import { paymentRoutes } from './payment';
import { registerTrackingRoutes } from './tracking';
import { userRoutes } from './user';
import { registerWalkerRoutes } from './walker';
import logger from '../../../shared/utils/logger';

/**
 * @description Registers all API routes by aggregating individual route modules.
 * Addresses requirement: Technical Specification/8.3 API Design/8.3.2 API Specifications
 * Provides a centralized entry point for all API routes in the API Gateway.
 * 
 * @param app - Express Router instance
 */
export const registerAllRoutes = (app: Router): void => {
  try {
    logger.logInfo('Starting API routes registration');

    // Register authentication routes
    logger.logInfo('Registering authentication routes');
    setupAuthRoutes(app);

    // Register booking routes
    logger.logInfo('Registering booking routes');
    app.post('/bookings', createBookingRoute);
    app.get('/bookings/:id', getBookingRoute);

    // Register payment routes
    logger.logInfo('Registering payment routes');
    app.post('/payments', paymentRoutes.createPaymentRoute);
    app.post('/payments/refund', paymentRoutes.refundPaymentRoute);
    app.post('/payments/webhook', paymentRoutes.webhookHandlerRoute);

    // Register tracking routes
    logger.logInfo('Registering tracking routes');
    registerTrackingRoutes(app);

    // Register user routes
    logger.logInfo('Registering user routes');
    app.use('/users', userRoutes);

    // Register walker routes
    logger.logInfo('Registering walker routes');
    registerWalkerRoutes(app);

    logger.logInfo('API routes registration completed successfully');
  } catch (error) {
    logger.logError('Failed to register API routes', { error });
    throw error;
  }
};