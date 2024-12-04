// class-validator v0.13.2
import { IsString, IsEmail, MinLength, IsDate, validateSync, ValidationError } from 'class-validator';
import { createHttpError } from '../utils/error';
import logger from '../utils/logger';

/**
 * @description Represents a user in the system with validation rules for its properties.
 * Addresses requirement: Technical Specification/8.2 Database Design/8.2.1 Schema Design
 * Ensures that user data is structured and validated according to the application's requirements.
 */
export class User {
    @IsString({ message: 'User ID must be a string' })
    id: string;

    @IsEmail({}, { message: 'Invalid email format' })
    email: string;

    @IsString({ message: 'Password must be a string' })
    @MinLength(8, { message: 'Password must be at least 8 characters long' })
    password: string;

    @IsString({ message: 'Name must be a string' })
    @MinLength(2, { message: 'Name must be at least 2 characters long' })
    name: string;

    @IsDate({ message: 'Created date must be a valid Date object' })
    createdAt: Date;

    @IsDate({ message: 'Updated date must be a valid Date object' })
    updatedAt: Date;

    /**
     * @description Initializes a new instance of the User class.
     * @param id - Unique identifier for the user
     * @param email - User's email address
     * @param password - User's password (hashed)
     * @param name - User's full name
     * @param createdAt - Timestamp when the user was created
     * @param updatedAt - Timestamp when the user was last updated
     */
    constructor(
        id: string,
        email: string,
        password: string,
        name: string,
        createdAt: Date,
        updatedAt: Date
    ) {
        this.id = id;
        this.email = email;
        this.password = password;
        this.name = name;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    /**
     * @description Validates the User instance using class-validator decorators.
     * Addresses requirement: Technical Specification/8.2 Database Design/8.2.1 Schema Design
     * @returns A promise resolving to an array of validation errors, if any.
     * @throws HttpError if validation fails
     */
    async validate(): Promise<ValidationError[]> {
        // Validate the current instance using class-validator
        const validationErrors = validateSync(this);

        // If there are validation errors, log them and throw an HTTP error
        if (validationErrors.length > 0) {
            logger.logError('User validation failed', {
                userId: this.id,
                errors: validationErrors.map(error => ({
                    property: error.property,
                    constraints: error.constraints
                }))
            });

            throw createHttpError(400, 'Invalid user data');
        }

        return validationErrors;
    }
}