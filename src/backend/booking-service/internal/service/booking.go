// Package service implements the business logic for the Booking Service
package service

import (
    "context"
    "fmt"
    "time"

    "src/backend/booking-service/internal/models"
    "src/backend/booking-service/internal/repository"
    "src/backend/booking-service/internal/config"
)

// Human Tasks:
// 1. Review and adjust booking validation rules based on business requirements
// 2. Set up monitoring for booking service metrics
// 3. Configure appropriate timeouts for service operations
// 4. Implement rate limiting for booking creation
// 5. Set up alerts for failed booking operations

// CreateBookingService handles the business logic for creating a new booking
// Addresses requirement: Technical Specification/1.3 Scope/Core Features/Booking System
// Handles real-time availability search, booking management, and schedule coordination
func CreateBookingService(ctx context.Context, booking *models.Booking) error {
    // Create context with timeout for the service operation
    ctx, cancel := context.WithTimeout(ctx, 10*time.Second)
    defer cancel()

    // Validate booking data
    if err := booking.Validate(); err != nil {
        return fmt.Errorf("invalid booking data: %w", err)
    }

    // Validate that the booking is scheduled in the future
    if !booking.IsScheduledInFuture() {
        return fmt.Errorf("booking must be scheduled for a future time")
    }

    // Validate that the booking is in a valid initial state
    if booking.Status != models.BookingStatusPending {
        return fmt.Errorf("new bookings must have 'pending' status")
    }

    // Create the booking in the database
    if err := repository.CreateBooking(ctx, booking); err != nil {
        return fmt.Errorf("failed to create booking: %w", err)
    }

    return nil
}

// GetBookingService handles the business logic for retrieving a booking by ID
// Addresses requirement: Technical Specification/1.3 Scope/Core Features/Booking System
// Handles booking management and retrieval
func GetBookingService(ctx context.Context, id string) (*models.Booking, error) {
    // Create context with timeout for the service operation
    ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
    defer cancel()

    // Validate booking ID
    if id == "" {
        return nil, fmt.Errorf("booking ID is required")
    }

    // Retrieve the booking from the database
    booking, err := repository.GetBookingByID(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("failed to retrieve booking: %w", err)
    }

    // Check if booking was found
    if booking == nil {
        return nil, fmt.Errorf("booking not found with id: %s", id)
    }

    return booking, nil
}