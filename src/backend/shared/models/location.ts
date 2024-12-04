// class-validator v0.13.2
import { IsNumber, IsString, IsLatitude, IsLongitude, validate } from 'class-validator';
import logger from '../../shared/utils/logger';
import { createHttpError } from '../../shared/utils/error';

/**
 * Represents a geographical location with latitude, longitude, and address.
 * Addresses requirement: Technical Specification/7.2.1 Core Components/Tracking Service
 * Handles real-time location processing for tracking dog walks.
 */
export class Location {
  @IsNumber()
  @IsLatitude()
  public latitude: number;

  @IsNumber()
  @IsLongitude()
  public longitude: number;

  @IsString()
  public address: string;

  /**
   * Initializes a Location instance with latitude, longitude, and address.
   * @param latitude - The geographical latitude coordinate
   * @param longitude - The geographical longitude coordinate
   * @param address - The human-readable address of the location
   */
  constructor(latitude: number, longitude: number, address: string) {
    this.latitude = latitude;
    this.longitude = longitude;
    this.address = address;
  }
}

/**
 * Validates a Location instance using class-validator decorators.
 * Addresses requirement: Technical Specification/7.2.1 Core Components/Tracking Service
 * Ensures location data integrity for real-time tracking.
 * 
 * @param location - The Location instance to validate
 * @returns A promise resolving to an array of validation errors, if any
 * @throws HttpError if validation fails
 */
export async function validateLocation(location: Location): Promise<any[]> {
  try {
    const validationErrors = await validate(location);
    
    if (validationErrors.length > 0) {
      logger.logError('Location validation failed', {
        errors: validationErrors,
        location: {
          latitude: location.latitude,
          longitude: location.longitude,
          address: location.address
        }
      });
      
      throw createHttpError(400, 'Invalid location data provided');
    }
    
    return validationErrors;
  } catch (error) {
    logger.logError('Error during location validation', { error });
    throw error;
  }
}