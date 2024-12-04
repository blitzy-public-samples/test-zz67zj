/**
 * Human Tasks:
 * 1. Set up Stripe webhook endpoint in production environment
 * 2. Configure monitoring alerts for payment failures
 * 3. Set up rate limiting for payment endpoints
 * 4. Ensure proper error tracking for payment processing issues
 * 5. Review and adjust payment validation rules based on business requirements
 */

// express v4.18.2
import { Request, Response } from 'express';
import { PaymentServiceModel } from '../models/payment';
import { processPayment, refundPayment } from '../services/stripe';
import logger from '../../../shared/utils/logger';
import { createHttpError } from '../../../shared/utils/error';

/**
 * @description Handles the creation of a new payment
 * Addresses requirement: Technical Specification/1.3 Scope/Core Features/Payments
 * Implements secure payment processing and automated billing.
 */
export const createPayment = async (req: Request, res: Response): Promise<void> => {
    try {
        logger.logInfo('Received payment creation request', {
            userId: req.body.userId,
            amount: req.body.amount,
            currency: req.body.currency
        });

        // Create and validate payment model
        const paymentModel = new PaymentServiceModel(
            req.body.id,
            req.body.userId,
            req.body.amount,
            req.body.currency,
            'pending',
            new Date(),
            new Date(),
            req.body.serviceSpecificProperty
        );

        // Validate service-specific logic
        await paymentModel.validateServiceSpecificLogic();

        // Process payment through Stripe
        const paymentResult = await processPayment(paymentModel);

        logger.logInfo('Payment processed successfully', {
            paymentId: paymentModel.id,
            stripePaymentIntentId: paymentResult.id,
            status: paymentResult.status
        });

        res.status(200).json({
            success: true,
            data: {
                paymentId: paymentModel.id,
                stripePaymentIntentId: paymentResult.id,
                status: paymentResult.status,
                clientSecret: paymentResult.client_secret
            }
        });
    } catch (error) {
        logger.logError('Payment creation failed', {
            error: error instanceof Error ? error.message : 'Unknown error',
            requestBody: req.body
        });

        if (error instanceof Error) {
            throw createHttpError(400, error.message);
        }
        throw error;
    }
};

/**
 * @description Processes a refund for a given payment
 * Addresses requirement: Technical Specification/1.3 Scope/Core Features/Payments
 * Implements secure refund processing.
 */
export const refundPayment = async (req: Request, res: Response): Promise<void> => {
    try {
        const { paymentId, amount } = req.body;

        logger.logInfo('Received refund request', {
            paymentId,
            amount
        });

        if (!paymentId || !amount) {
            throw createHttpError(400, 'Payment ID and amount are required for refund');
        }

        // Process refund through Stripe
        const refundResult = await refundPayment(paymentId, amount);

        logger.logInfo('Refund processed successfully', {
            paymentId,
            refundId: refundResult.id,
            status: refundResult.status
        });

        res.status(200).json({
            success: true,
            data: {
                refundId: refundResult.id,
                status: refundResult.status,
                amount: refundResult.amount
            }
        });
    } catch (error) {
        logger.logError('Refund processing failed', {
            error: error instanceof Error ? error.message : 'Unknown error',
            requestBody: req.body
        });

        if (error instanceof Error) {
            throw createHttpError(400, error.message);
        }
        throw error;
    }
};

/**
 * @description Handles incoming Stripe webhook events
 * Addresses requirement: Technical Specification/1.3 Scope/Core Features/Payments
 * Implements webhook handling for payment status updates.
 */
export const webhookHandler = async (req: Request, res: Response): Promise<void> => {
    try {
        const event = req.body;

        logger.logInfo('Received Stripe webhook event', {
            eventType: event.type,
            eventId: event.id
        });

        // Handle different event types
        switch (event.type) {
            case 'payment_intent.succeeded':
                await handlePaymentSuccess(event.data.object);
                break;
            case 'payment_intent.payment_failed':
                await handlePaymentFailure(event.data.object);
                break;
            case 'charge.refunded':
                await handleRefundSuccess(event.data.object);
                break;
            default:
                logger.logInfo('Unhandled webhook event type', { eventType: event.type });
        }

        res.status(200).json({ received: true });
    } catch (error) {
        logger.logError('Webhook processing failed', {
            error: error instanceof Error ? error.message : 'Unknown error',
            eventType: req.body.type
        });

        if (error instanceof Error) {
            throw createHttpError(400, error.message);
        }
        throw error;
    }
};

/**
 * @description Handles successful payment webhook events
 * @param paymentIntent - The Stripe PaymentIntent object
 */
async function handlePaymentSuccess(paymentIntent: any): Promise<void> {
    logger.logInfo('Processing successful payment webhook', {
        paymentIntentId: paymentIntent.id,
        amount: paymentIntent.amount,
        currency: paymentIntent.currency
    });

    // Update payment status in database
    // Note: Implementation would depend on database service
    // TODO: Implement database update logic
}

/**
 * @description Handles failed payment webhook events
 * @param paymentIntent - The Stripe PaymentIntent object
 */
async function handlePaymentFailure(paymentIntent: any): Promise<void> {
    logger.logError('Processing failed payment webhook', {
        paymentIntentId: paymentIntent.id,
        error: paymentIntent.last_payment_error
    });

    // Update payment status in database
    // Note: Implementation would depend on database service
    // TODO: Implement database update logic
}

/**
 * @description Handles successful refund webhook events
 * @param charge - The Stripe Charge object
 */
async function handleRefundSuccess(charge: any): Promise<void> {
    logger.logInfo('Processing successful refund webhook', {
        chargeId: charge.id,
        refundAmount: charge.amount_refunded
    });

    // Update payment status in database
    // Note: Implementation would depend on database service
    // TODO: Implement database update logic
}