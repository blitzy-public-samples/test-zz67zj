/**
 * Human Tasks:
 * 1. Set up a Stripe account and obtain API keys
 * 2. Configure webhook endpoints in Stripe dashboard
 * 3. Set up proper error monitoring and alerts for payment failures
 * 4. Ensure PCI compliance requirements are met
 * 5. Configure rate limiting for payment endpoints
 */

// stripe v10.0.0
import Stripe from 'stripe';
import { STRIPE_API_KEY } from '../config';
import { PaymentServiceModel } from '../models/payment';
import logger from '../../../shared/utils/logger';
import { createHttpError } from '../../../shared/utils/error';

// Global variable to store Stripe client instance
let stripeClient: Stripe;

/**
 * Initializes the Stripe client with the API key from configuration.
 * Addresses requirement: Technical Specification/1.3 Scope/Core Features/Payments
 * Ensures secure payment processing setup with Stripe.
 */
export const initializeStripe = (): void => {
  try {
    stripeClient = new Stripe(STRIPE_API_KEY, {
      apiVersion: '2022-11-15', // Lock API version for stability
      typescript: true,
    });
    
    logger.logInfo('Stripe client initialized successfully');
  } catch (error) {
    logger.logError('Failed to initialize Stripe client', { error });
    throw createHttpError(500, 'Payment service initialization failed');
  }
};

/**
 * Processes a payment using the Stripe API.
 * Addresses requirement: Technical Specification/1.3 Scope/Core Features/Payments
 * Handles secure payment processing and automated billing.
 * 
 * @param paymentData - Payment data model containing transaction details
 * @returns Promise resolving to Stripe payment response
 * @throws HttpError if payment processing fails
 */
export const processPayment = async (paymentData: PaymentServiceModel): Promise<Stripe.Response<Stripe.PaymentIntent>> => {
  try {
    // Validate payment data using service-specific logic
    await paymentData.validateServiceSpecificLogic();

    logger.logInfo('Initiating payment processing', {
      paymentId: paymentData.id,
      amount: paymentData.amount,
      currency: paymentData.currency
    });

    // Create a payment intent with Stripe
    const paymentIntent = await stripeClient.paymentIntents.create({
      amount: paymentData.amount, // Amount in smallest currency unit (e.g., cents)
      currency: paymentData.currency.toLowerCase(),
      metadata: {
        paymentId: paymentData.id,
        userId: paymentData.userId
      },
      description: `Payment ${paymentData.id} for user ${paymentData.userId}`,
      statement_descriptor: 'PAWSOME PAYMENT', // Max 22 characters
      capture_method: 'automatic',
      confirm: true,
      automatic_payment_methods: {
        enabled: true,
        allow_redirects: 'always'
      }
    });

    logger.logInfo('Payment processed successfully', {
      paymentId: paymentData.id,
      stripePaymentIntentId: paymentIntent.id,
      status: paymentIntent.status
    });

    return paymentIntent;
  } catch (error) {
    logger.logError('Payment processing failed', {
      paymentId: paymentData.id,
      error: error instanceof Error ? error.message : 'Unknown error'
    });

    if (error instanceof Stripe.errors.StripeError) {
      throw createHttpError(400, `Payment failed: ${error.message}`);
    }
    throw error;
  }
};

/**
 * Processes a refund for a payment using the Stripe API.
 * Addresses requirement: Technical Specification/1.3 Scope/Core Features/Payments
 * Handles secure refund processing.
 * 
 * @param paymentId - ID of the payment to refund
 * @param amount - Amount to refund in smallest currency unit
 * @returns Promise resolving to Stripe refund response
 * @throws HttpError if refund processing fails
 */
export const refundPayment = async (paymentId: string, amount: number): Promise<Stripe.Response<Stripe.Refund>> => {
  try {
    logger.logInfo('Initiating payment refund', {
      paymentId,
      amount
    });

    // Create a refund with Stripe
    const refund = await stripeClient.refunds.create({
      payment_intent: paymentId,
      amount: amount,
      reason: 'requested_by_customer'
    });

    logger.logInfo('Refund processed successfully', {
      paymentId,
      refundId: refund.id,
      status: refund.status
    });

    return refund;
  } catch (error) {
    logger.logError('Refund processing failed', {
      paymentId,
      amount,
      error: error instanceof Error ? error.message : 'Unknown error'
    });

    if (error instanceof Stripe.errors.StripeError) {
      throw createHttpError(400, `Refund failed: ${error.message}`);
    }
    throw error;
  }
};