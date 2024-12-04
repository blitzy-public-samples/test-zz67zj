/**
 * Human Tasks:
 * 1. Configure test environment variables for Stripe API keys
 * 2. Set up test database with proper test data
 * 3. Configure test coverage reporting thresholds
 * 4. Review and maintain test cases as payment requirements evolve
 */

// jest v29.0.0
// supertest v6.3.0
import request from 'supertest';
import { PaymentServiceModel } from '../src/models/payment';
import { processPayment, refundPayment } from '../src/services/stripe';
import { createPayment, refundPayment as refundPaymentController, webhookHandler } from '../src/controllers/payment';
import { createHttpError } from '../../../shared/utils/error';

// Mock the required dependencies
jest.mock('../src/models/payment');
jest.mock('../src/services/stripe');
jest.mock('../../../shared/utils/logger');

/**
 * Payment Service Test Suite
 * Addresses requirement: Technical Specification/1.3 Scope/Core Features/Payments
 * Ensures secure payment processing, automated billing, and receipt generation through rigorous testing.
 */
describe('Payment Service Tests', () => {
    let mockRequest: any;
    let mockResponse: any;

    beforeEach(() => {
        // Reset all mocks before each test
        jest.clearAllMocks();

        // Mock Express request and response objects
        mockRequest = {
            body: {
                id: 'test-payment-id',
                userId: 'test-user-id',
                amount: 1000,
                currency: 'USD',
                serviceSpecificProperty: 'test-property'
            }
        };

        mockResponse = {
            status: jest.fn().mockReturnThis(),
            json: jest.fn()
        };
    });

    describe('Payment Processing Tests', () => {
        it('should successfully process a valid payment', async () => {
            // Mock successful payment validation
            (PaymentServiceModel.prototype.validateServiceSpecificLogic as jest.Mock).mockResolvedValueOnce([]);

            // Mock successful Stripe payment processing
            (processPayment as jest.Mock).mockResolvedValueOnce({
                id: 'stripe-payment-id',
                status: 'succeeded',
                client_secret: 'test-client-secret'
            });

            await createPayment(mockRequest, mockResponse);

            expect(mockResponse.status).toHaveBeenCalledWith(200);
            expect(mockResponse.json).toHaveBeenCalledWith({
                success: true,
                data: {
                    paymentId: 'test-payment-id',
                    stripePaymentIntentId: 'stripe-payment-id',
                    status: 'succeeded',
                    clientSecret: 'test-client-secret'
                }
            });
        });

        it('should handle payment validation errors', async () => {
            // Mock validation failure
            const validationError = createHttpError(400, 'Invalid payment data');
            (PaymentServiceModel.prototype.validateServiceSpecificLogic as jest.Mock)
                .mockRejectedValueOnce(validationError);

            await expect(createPayment(mockRequest, mockResponse))
                .rejects
                .toThrow('Invalid payment data');
        });

        it('should handle Stripe processing errors', async () => {
            // Mock successful validation but failed payment processing
            (PaymentServiceModel.prototype.validateServiceSpecificLogic as jest.Mock).mockResolvedValueOnce([]);
            (processPayment as jest.Mock).mockRejectedValueOnce(new Error('Stripe processing failed'));

            await expect(createPayment(mockRequest, mockResponse))
                .rejects
                .toThrow('Stripe processing failed');
        });
    });

    describe('Refund Processing Tests', () => {
        beforeEach(() => {
            mockRequest.body = {
                paymentId: 'test-payment-id',
                amount: 1000
            };
        });

        it('should successfully process a valid refund', async () => {
            // Mock successful Stripe refund processing
            (refundPayment as jest.Mock).mockResolvedValueOnce({
                id: 'refund-id',
                status: 'succeeded',
                amount: 1000
            });

            await refundPaymentController(mockRequest, mockResponse);

            expect(mockResponse.status).toHaveBeenCalledWith(200);
            expect(mockResponse.json).toHaveBeenCalledWith({
                success: true,
                data: {
                    refundId: 'refund-id',
                    status: 'succeeded',
                    amount: 1000
                }
            });
        });

        it('should handle missing refund parameters', async () => {
            mockRequest.body = {};

            await expect(refundPaymentController(mockRequest, mockResponse))
                .rejects
                .toThrow('Payment ID and amount are required for refund');
        });

        it('should handle Stripe refund errors', async () => {
            (refundPayment as jest.Mock).mockRejectedValueOnce(new Error('Refund processing failed'));

            await expect(refundPaymentController(mockRequest, mockResponse))
                .rejects
                .toThrow('Refund processing failed');
        });
    });

    describe('Webhook Handling Tests', () => {
        beforeEach(() => {
            mockRequest.body = {
                id: 'evt_test',
                type: 'payment_intent.succeeded',
                data: {
                    object: {
                        id: 'pi_test',
                        amount: 1000,
                        currency: 'USD'
                    }
                }
            };
        });

        it('should handle successful payment webhook events', async () => {
            await webhookHandler(mockRequest, mockResponse);

            expect(mockResponse.status).toHaveBeenCalledWith(200);
            expect(mockResponse.json).toHaveBeenCalledWith({ received: true });
        });

        it('should handle failed payment webhook events', async () => {
            mockRequest.body.type = 'payment_intent.payment_failed';
            mockRequest.body.data.object.last_payment_error = 'Test error';

            await webhookHandler(mockRequest, mockResponse);

            expect(mockResponse.status).toHaveBeenCalledWith(200);
            expect(mockResponse.json).toHaveBeenCalledWith({ received: true });
        });

        it('should handle refund webhook events', async () => {
            mockRequest.body.type = 'charge.refunded';
            mockRequest.body.data.object.amount_refunded = 1000;

            await webhookHandler(mockRequest, mockResponse);

            expect(mockResponse.status).toHaveBeenCalledWith(200);
            expect(mockResponse.json).toHaveBeenCalledWith({ received: true });
        });

        it('should handle unknown webhook events', async () => {
            mockRequest.body.type = 'unknown.event';

            await webhookHandler(mockRequest, mockResponse);

            expect(mockResponse.status).toHaveBeenCalledWith(200);
            expect(mockResponse.json).toHaveBeenCalledWith({ received: true });
        });

        it('should handle webhook processing errors', async () => {
            mockRequest.body = null;

            await expect(webhookHandler(mockRequest, mockResponse))
                .rejects
                .toThrow();
        });
    });
});