// Package models defines the core data models for the booking service
package models

import (
    "time"
)

// Human Tasks:
// 1. Ensure database migrations are created for the Booking table
// 2. Configure appropriate database indexes for scheduledAt and status fields
// 3. Set up monitoring for booking-related metrics
// 4. Review and adjust booking status enum values based on business requirements

// BookingStatus represents the current state of a booking
type BookingStatus string

// Booking status constants
const (
    BookingStatusPending    BookingStatus = "pending"
    BookingStatusConfirmed  BookingStatus = "confirmed"
    BookingStatusInProgress BookingStatus = "in_progress"
    BookingStatusCompleted  BookingStatus = "completed"
    BookingStatusCancelled  BookingStatus = "cancelled"
    BookingStatusFailed     BookingStatus = "failed"
)

// Booking represents a dog walking appointment with details about the user, walker, and schedule.
// Addresses requirement: Technical Specification/1.3 Scope/Core Features/Booking System
// Handles real-time availability search, booking management, and schedule coordination.
type Booking struct {
    // Unique identifier for the booking
    ID string `json:"id" db:"id"`

    // ID of the dog owner who created the booking
    OwnerID string `json:"owner_id" db:"owner_id"`

    // ID of the assigned dog walker
    WalkerID string `json:"walker_id" db:"walker_id"`

    // ID of the dog to be walked
    DogID string `json:"dog_id" db:"dog_id"`

    // Scheduled time for the walk
    ScheduledAt time.Time `json:"scheduled_at" db:"scheduled_at"`

    // Current status of the booking
    Status BookingStatus `json:"status" db:"status"`

    // Cost of the booking in the system's default currency (USD)
    Amount float64 `json:"amount" db:"amount"`
}

// NewBooking creates a new instance of the Booking struct with the provided parameters.
// Addresses requirement: Technical Specification/1.3 Scope/Core Features/Booking System
func NewBooking(
    id string,
    ownerID string,
    walkerID string,
    dogID string,
    scheduledAt time.Time,
    status BookingStatus,
    amount float64,
) *Booking {
    return &Booking{
        ID:          id,
        OwnerID:     ownerID,
        WalkerID:    walkerID,
        DogID:       dogID,
        ScheduledAt: scheduledAt,
        Status:      status,
        Amount:      amount,
    }
}

// Validate performs basic validation on the booking data.
// Returns an error if any required fields are missing or invalid.
func (b *Booking) Validate() error {
    if b.ID == "" {
        return fmt.Errorf("booking ID is required")
    }
    if b.OwnerID == "" {
        return fmt.Errorf("owner ID is required")
    }
    if b.WalkerID == "" {
        return fmt.Errorf("walker ID is required")
    }
    if b.DogID == "" {
        return fmt.Errorf("dog ID is required")
    }
    if b.ScheduledAt.IsZero() {
        return fmt.Errorf("scheduled time is required")
    }
    if b.Status == "" {
        return fmt.Errorf("status is required")
    }
    if b.Amount < 0 {
        return fmt.Errorf("amount must be non-negative")
    }
    return nil
}

// IsScheduledInFuture checks if the booking is scheduled for a future time.
func (b *Booking) IsScheduledInFuture() bool {
    return b.ScheduledAt.After(time.Now())
}

// IsCancellable determines if the booking can be cancelled based on its current status.
func (b *Booking) IsCancellable() bool {
    return b.Status == BookingStatusPending || b.Status == BookingStatusConfirmed
}

// IsModifiable determines if the booking details can be modified based on its current status.
func (b *Booking) IsModifiable() bool {
    return b.Status == BookingStatusPending
}

// UpdateStatus changes the booking status and validates the transition.
func (b *Booking) UpdateStatus(newStatus BookingStatus) error {
    // Validate status transition
    validTransition := false
    switch b.Status {
    case BookingStatusPending:
        validTransition = newStatus == BookingStatusConfirmed || 
                         newStatus == BookingStatusCancelled
    case BookingStatusConfirmed:
        validTransition = newStatus == BookingStatusInProgress || 
                         newStatus == BookingStatusCancelled
    case BookingStatusInProgress:
        validTransition = newStatus == BookingStatusCompleted || 
                         newStatus == BookingStatusFailed
    case BookingStatusCompleted, BookingStatusCancelled, BookingStatusFailed:
        validTransition = false
    }

    if !validTransition {
        return fmt.Errorf("invalid status transition from %s to %s", b.Status, newStatus)
    }

    b.Status = newStatus
    return nil
}

// TimeUntilScheduled returns the duration until the scheduled time.
func (b *Booking) TimeUntilScheduled() time.Duration {
    return time.Until(b.ScheduledAt)
}

// IsOverdue checks if the booking is past its scheduled time without being started.
func (b *Booking) IsOverdue() bool {
    return time.Now().After(b.ScheduledAt) && 
           b.Status != BookingStatusInProgress && 
           b.Status != BookingStatusCompleted && 
           b.Status != BookingStatusCancelled && 
           b.Status != BookingStatusFailed
}