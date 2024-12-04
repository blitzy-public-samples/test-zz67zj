// class-validator v0.13.2
import { IsString, IsEmail, MinLength, IsDate, validateSync, ValidationError } from 'class-validator';
import { createHttpError } from '../../../shared/utils/error';
import logger from '../../../shared/utils/logger';

/**
 * Represents a user in the authentication service with validation rules.
 * Addresses requirement: Technical Specification/8.2 Database Design/8.2.1 Schema Design
 * Ensures that user data is structured and validated according to the application's requirements.
 */
export class AuthUser {
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
   * Creates a new instance of AuthUser with the provided data.
   * Addresses requirement: Technical Specification/8.2 Database Design/8.2.1 Schema Design
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
   * Validates the AuthUser instance using class-validator decorators.
   * Addresses requirement: Technical Specification/8.2 Database Design/8.2.1 Schema Design
   * @returns A promise resolving to an array of validation errors, if any
   * @throws HttpError if validation fails
   */
  async validate(): Promise<ValidationError[]> {
    const validationErrors = validateSync(this);

    if (validationErrors.length > 0) {
      logger.logError('User validation failed', {
        errors: validationErrors,
        userId: this.id,
        email: this.email
      });

      throw createHttpError(400, 'Invalid user data provided');
    }

    return validationErrors;
  }
}