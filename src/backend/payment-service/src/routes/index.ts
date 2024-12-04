/**
 * Human Tasks:
 * 1. Set up rate limiting middleware for payment endpoints
 * 2. Configure monitoring alerts for payment endpoint failures
 * 3. Set up proper error tracking for payment routes
 * 4. Review and adjust API endpoint security measures
 */

// express v4.18.2
import express, { Router } from 'express';
import { createPayment, refundPayment, webhookHandler } from '../controllers/payment';

/**
 * @description Sets up the HTTP routes for the Payment Service, mapping endpoints to their respective controller functions.
 * Addresses requirement: Technical Specification/1.3 Scope/Core Features/Payments
 * Implements secure payment processing, refunds, and webhook handling for payment status updates.
 * 
 * @param app - Express application instance
 */
export const setupRoutes = (app: express.Application): void => {
    // Create a new router instance
    const router: Router = express.Router();

    /**
     * POST /payments
     * Creates a new payment
     * Addresses requirement: Technical Specification/1.3 Scope/Core Features/Payments
     * Implements secure payment processing and automated billing
     */
    router.post('/payments', createPayment);

    /**
     * POST /payments/refund
     * Processes a refund for a payment
     * Addresses requirement: Technical Specification/1.3 Scope/Core Features/Payments
     * Implements secure refund processing
     */
    router.post('/payments/refund', refundPayment);

    /**
     * POST /payments/webhook
     * Handles Stripe webhook events for payment status updates
     * Addresses requirement: Technical Specification/1.3 Scope/Core Features/Payments
     * Implements webhook handling for payment status updates
     */
    router.post('/payments/webhook', webhookHandler);

    // Mount the router on the app
    app.use(router);
};