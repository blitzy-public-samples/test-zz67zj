/**
 * Human Tasks:
 * 1. Configure monitoring alerts for payment validation failures
 * 2. Set up error tracking for payment-specific validation errors
 * 3. Review and adjust service-specific validation rules based on business requirements
 * 4. Ensure proper error handling and logging configuration for payment service
 */

// class-validator v0.13.2
import { IsString, validateSync, ValidationError } from 'class-validator';
import { Payment, validate } from '../../../shared/models/payment';
import { validatePayment } from '../../../shared/utils/validation';
import { createHttpError } from '../../../shared/utils/error';

/**
 * @description Extends the shared Payment model to include service-specific properties and methods.
 * Addresses requirement: Technical Specification/1.3 Scope/Core Features/Payments
 * The Payment model is essential for managing secure payment processing, automated billing, and receipt generation.
 */
export class PaymentServiceModel extends Payment {
    @IsString({ message: 'Service specific property must be a string' })
    serviceSpecificProperty: string;

    /**
     * @description Initializes a new PaymentServiceModel instance with default values.
     * Addresses requirement: Technical Specification/1.3 Scope/Core Features/Payments
     * 
     * @param id - Unique identifier for the payment
     * @param userId - ID of the user making the payment
     * @param amount - Payment amount
     * @param currency - Payment currency code
     * @param status - Current status of the payment
     * @param createdAt - Timestamp when the payment was created
     * @param updatedAt - Timestamp when the payment was last updated
     * @param serviceSpecificProperty - Additional property specific to the payment service
     */
    constructor(
        id: string,
        userId: string,
        amount: number,
        currency: string,
        status: string,
        createdAt: Date = new Date(),
        updatedAt: Date = new Date(),
        serviceSpecificProperty: string
    ) {
        // Call the parent Payment class constructor
        super(id, userId, amount, currency, status, createdAt, updatedAt);
        this.serviceSpecificProperty = serviceSpecificProperty;
    }

    /**
     * @description Validates service-specific logic for the PaymentServiceModel instance.
     * Addresses requirement: Technical Specification/1.3 Scope/Core Features/Payments
     * Ensures payment data integrity and validation before processing.
     * 
     * @returns A promise resolving to an array of validation errors, if any.
     * @throws HttpError if validation fails
     */
    async validateServiceSpecificLogic(): Promise<ValidationError[]> {
        try {
            // First validate the base payment model
            await super.validate();

            // Validate the payment using the shared validation utility
            await validatePayment(this);

            // Perform service-specific validation
            const serviceValidationErrors = validateSync(this);

            if (serviceValidationErrors.length > 0) {
                throw createHttpError(400, 'Invalid payment service data');
            }

            return serviceValidationErrors;
        } catch (error) {
            // Re-throw the error to maintain consistent error handling
            throw error;
        }
    }
}