// class-validator v0.13.2
import { IsString, IsNumber, IsDate, IsEnum, validateSync, ValidationError } from 'class-validator';
import { User } from './user';
import { createHttpError } from '../utils/error';

/**
 * @description Represents a payment in the system with validation rules for its properties.
 * Addresses requirement: Technical Specification/1.3 Scope/Core Features/Payments
 * Ensures secure payment processing, automated billing, and receipt generation.
 */
export class Payment {
    @IsString({ message: 'Payment ID must be a string' })
    id: string;

    @IsString({ message: 'User ID must be a string' })
    userId: string;

    @IsNumber({}, { message: 'Amount must be a number' })
    amount: number;

    @IsString({ message: 'Currency must be a string' })
    currency: string;

    @IsEnum(['pending', 'processing', 'completed', 'failed', 'refunded'], {
        message: 'Invalid payment status'
    })
    status: string;

    @IsDate({ message: 'Created date must be a valid Date object' })
    createdAt: Date;

    @IsDate({ message: 'Updated date must be a valid Date object' })
    updatedAt: Date;

    /**
     * @description Initializes a new Payment instance with provided values.
     * Addresses requirement: Technical Specification/1.3 Scope/Core Features/Payments
     * @param id - Unique identifier for the payment
     * @param userId - ID of the user making the payment
     * @param amount - Payment amount
     * @param currency - Payment currency code (e.g., 'USD')
     * @param status - Current status of the payment
     * @param createdAt - Timestamp when the payment was created
     * @param updatedAt - Timestamp when the payment was last updated
     */
    constructor(
        id: string,
        userId: string,
        amount: number,
        currency: string,
        status: string,
        createdAt: Date = new Date(),
        updatedAt: Date = new Date()
    ) {
        this.id = id;
        this.userId = userId;
        this.amount = amount;
        this.currency = currency;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    /**
     * @description Validates the Payment instance using class-validator decorators.
     * Addresses requirement: Technical Specification/1.3 Scope/Core Features/Payments
     * Ensures payment data integrity and validation before processing.
     * @returns A promise resolving to an array of validation errors, if any.
     * @throws HttpError if validation fails
     */
    async validate(): Promise<ValidationError[]> {
        // Validate the current instance using class-validator
        const validationErrors = validateSync(this);

        // If there are validation errors, throw an HTTP error
        if (validationErrors.length > 0) {
            throw createHttpError(400, 'Invalid payment data');
        }

        return validationErrors;
    }
}