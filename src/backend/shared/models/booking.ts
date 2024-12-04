// class-validator v0.13.2
import { IsString, IsDate, IsEnum, validate, ValidationError } from 'class-validator';
import { Location } from './location';
import { Payment } from './payment';
import { User } from './user';
import { createHttpError } from '../utils/error';

/**
 * Human Tasks:
 * 1. Ensure database indexes are created for frequently queried fields (id, user.id, status)
 * 2. Configure appropriate monitoring for booking validation errors
 * 3. Set up alerts for high booking failure rates
 * 4. Review and adjust booking status transition rules based on business requirements
 */

/**
 * Represents a booking entity with details about the user, location, payment, and schedule.
 * Addresses requirement: Technical Specification/8.2 Database Design/Schema Design
 * The booking model is used to represent booking-related data such as schedules, users, and payments.
 */
export class Booking {
    @IsString({ message: 'Booking ID must be a string' })
    public id: string;

    /**
     * The user who created the booking
     */
    public user: User;

    /**
     * The location where the service will be provided
     */
    public location: Location;

    /**
     * The payment associated with this booking
     */
    public payment: Payment;

    @IsDate({ message: 'Scheduled time must be a valid date' })
    public scheduledAt: Date;

    @IsEnum(['pending', 'confirmed', 'in_progress', 'completed', 'cancelled'], {
        message: 'Invalid booking status'
    })
    public status: string;

    /**
     * Initializes a new instance of the Booking class.
     * @param id - Unique identifier for the booking
     * @param user - User who created the booking
     * @param location - Location where the service will be provided
     * @param payment - Payment associated with the booking
     * @param scheduledAt - When the service is scheduled
     * @param status - Current status of the booking
     */
    constructor(
        id: string,
        user: User,
        location: Location,
        payment: Payment,
        scheduledAt: Date,
        status: string
    ) {
        this.id = id;
        this.user = user;
        this.location = location;
        this.payment = payment;
        this.scheduledAt = scheduledAt;
        this.status = status;
    }

    /**
     * Validates the booking instance using class-validator decorators.
     * Addresses requirement: Technical Specification/8.2 Database Design/Schema Design
     * Ensures booking data integrity and validation before processing.
     * @returns A promise resolving to an array of validation errors, if any.
     * @throws HttpError if validation fails
     */
    public async validate(): Promise<ValidationError[]> {
        return await validateBooking(this);
    }
}

/**
 * Validates a booking instance using class-validator decorators.
 * @param booking - The booking instance to validate
 * @returns A promise resolving to an array of validation errors, if any
 * @throws HttpError if validation fails
 */
export async function validateBooking(booking: Booking): Promise<ValidationError[]> {
    // Validate the booking instance
    const validationErrors = await validate(booking);

    // Validate the associated user
    if (booking.user) {
        const userValidationErrors = await booking.user.validate();
        validationErrors.push(...userValidationErrors);
    }

    // Validate the associated location
    if (booking.location) {
        const locationValidationErrors = await validate(booking.location);
        validationErrors.push(...locationValidationErrors);
    }

    // Validate the associated payment
    if (booking.payment) {
        const paymentValidationErrors = await booking.payment.validate();
        validationErrors.push(...paymentValidationErrors);
    }

    // If there are any validation errors, throw an HTTP error
    if (validationErrors.length > 0) {
        throw createHttpError(400, 'Invalid booking data');
    }

    return validationErrors;
}