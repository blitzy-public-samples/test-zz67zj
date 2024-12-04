// Package repository implements the data access layer for the Booking Service
package repository

import (
    "context"
    "database/sql"
    "fmt"
    _ "github.com/lib/pq" // v1.10.0 - PostgreSQL driver
    "time"

    "src/backend/booking-service/internal/models"
    "src/backend/booking-service/internal/config"
)

// Human Tasks:
// 1. Ensure PostgreSQL is installed and running
// 2. Create the bookings table with appropriate schema
// 3. Set up database indexes for frequently queried fields (id, owner_id, walker_id, scheduled_at)
// 4. Configure connection pool settings based on load testing results
// 5. Implement database monitoring and alerting
// 6. Set up regular database backups
// 7. Review and adjust query timeout settings based on performance requirements

// DB is a global variable holding the database connection pool
var DB *sql.DB

// InitDB initializes the database connection pool using the provided configuration
// Addresses requirement: Technical Specification/1.3 Scope/Core Features/Booking System
func InitDB(cfg *config.Config) error {
    var err error
    DB, err = sql.Open("postgres", cfg.DatabaseURL)
    if err != nil {
        return fmt.Errorf("failed to open database connection: %w", err)
    }

    // Configure connection pool settings
    DB.SetMaxOpenConns(25)
    DB.SetMaxIdleConns(5)
    DB.SetConnMaxLifetime(5 * time.Minute)

    // Verify database connection
    if err = DB.Ping(); err != nil {
        return fmt.Errorf("failed to ping database: %w", err)
    }

    return nil
}

// CreateBooking inserts a new booking record into the PostgreSQL database
// Addresses requirement: Technical Specification/1.3 Scope/Core Features/Booking System
func CreateBooking(ctx context.Context, booking *models.Booking) error {
    query := `
        INSERT INTO bookings (
            id, owner_id, walker_id, dog_id, scheduled_at, status, amount
        ) VALUES (
            $1, $2, $3, $4, $5, $6, $7
        )`

    // Create context with timeout for the database operation
    ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
    defer cancel()

    // Execute the insert query
    _, err := DB.ExecContext(ctx, query,
        booking.ID,
        booking.OwnerID,
        booking.WalkerID,
        booking.DogID,
        booking.ScheduledAt,
        booking.Status,
        booking.Amount,
    )

    if err != nil {
        return fmt.Errorf("failed to create booking: %w", err)
    }

    return nil
}

// GetBookingByID retrieves a booking record from the PostgreSQL database by its ID
// Addresses requirement: Technical Specification/1.3 Scope/Core Features/Booking System
func GetBookingByID(ctx context.Context, id string) (*models.Booking, error) {
    query := `
        SELECT id, owner_id, walker_id, dog_id, scheduled_at, status, amount
        FROM bookings
        WHERE id = $1`

    // Create context with timeout for the database operation
    ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
    defer cancel()

    booking := &models.Booking{}
    err := DB.QueryRowContext(ctx, query, id).Scan(
        &booking.ID,
        &booking.OwnerID,
        &booking.WalkerID,
        &booking.DogID,
        &booking.ScheduledAt,
        &booking.Status,
        &booking.Amount,
    )

    if err == sql.ErrNoRows {
        return nil, fmt.Errorf("booking not found with id: %s", id)
    }

    if err != nil {
        return nil, fmt.Errorf("failed to get booking: %w", err)
    }

    return booking, nil
}

// Close closes the database connection pool
func Close() error {
    if DB != nil {
        return DB.Close()
    }
    return nil
}