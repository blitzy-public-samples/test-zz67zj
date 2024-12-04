/**
 * Human Tasks:
 * 1. Configure rate limiting for payment endpoints
 * 2. Set up monitoring alerts for payment failures
 * 3. Configure webhook endpoint URL in Stripe dashboard
 * 4. Ensure proper error tracking for payment processing issues
 * 5. Review and adjust payment validation rules based on business requirements
 */

// express v4.18.2
import { Router, Request, Response, NextFunction } from 'express';

// Import validation and authentication middleware
import { authenticateRequest } from '../middleware/auth';
import { validateRequest } from '../middleware/validation';

// Import payment-related functions and models
import { Payment } from '../../../shared/models/payment';
import { validatePayment } from '../../../shared/utils/validation';
import { createHttpError } from '../../../shared/utils/error';
import { 
  createPayment, 
  refundPayment, 
  webhookHandler 
} from '../../../payment-service/src/controllers/payment';

/**
 * @description Defines the route for creating a new payment
 * Addresses requirement: Technical Specification/8.3 API Design/API Specifications
 */
export const createPaymentRoute = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    // Validate the payment data using the Payment model
    const paymentData = new Payment(
      req.body.id,
      req.body.userId,
      req.body.amount,
      req.body.currency,
      'pending',
      new Date(),
      new Date()
    );

    await validatePayment(paymentData);

    // Process the payment using the payment service
    const result = await createPayment(req, res);
    res.status(200).json(result);
  } catch (error) {
    next(error);
  }
};

/**
 * @description Defines the route for processing a payment refund
 * Addresses requirement: Technical Specification/8.3 API Design/API Specifications
 */
export const refundPaymentRoute = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    // Validate refund request data
    if (!req.body.paymentId || !req.body.amount) {
      throw createHttpError(400, 'Payment ID and amount are required for refund');
    }

    // Process the refund using the payment service
    const result = await refundPayment(req, res);
    res.status(200).json(result);
  } catch (error) {
    next(error);
  }
};

/**
 * @description Defines the route for handling Stripe webhook events
 * Addresses requirement: Technical Specification/8.3 API Design/API Specifications
 */
export const webhookHandlerRoute = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    // Process the webhook event using the payment service
    await webhookHandler(req, res);
    res.status(200).json({ received: true });
  } catch (error) {
    next(error);
  }
};

// Create an Express router instance
const router = Router();

// Define payment routes with appropriate middleware
router.post(
  '/payments',
  authenticateRequest,
  validateRequest(Payment),
  createPaymentRoute
);

router.post(
  '/payments/refund',
  authenticateRequest,
  refundPaymentRoute
);

// Webhook route doesn't require authentication as it's called by Stripe
router.post(
  '/payments/webhook',
  webhookHandlerRoute
);

// Export the router with all payment routes
export default router;

// Export individual route handlers for testing and reuse
export const paymentRoutes = {
  createPaymentRoute,
  refundPaymentRoute,
  webhookHandlerRoute
};