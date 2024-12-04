// Package handlers implements HTTP handlers for the Booking Service
package handlers

import (
    "context"
    "encoding/json"
    "fmt"
    "net/http"
    "strings"

    "src/backend/booking-service/internal/models"
    "src/backend/booking-service/internal/service"
    "src/backend/shared/utils/logger"
)

// Human Tasks:
// 1. Configure rate limiting for the booking endpoints
// 2. Set up request tracing and monitoring
// 3. Implement authentication middleware
// 4. Configure CORS settings if needed
// 5. Set up API documentation using Swagger/OpenAPI

// CreateBookingHandler handles HTTP POST requests to create a new booking
// Addresses requirement: Technical Specification/1.3 Scope/Core Features/Booking System
// Handles real-time availability search, booking management, and schedule coordination
func CreateBookingHandler(w http.ResponseWriter, r *http.Request) {
    // Set response content type
    w.Header().Set("Content-Type", "application/json")

    // Parse request body
    var booking models.Booking
    if err := json.NewDecoder(r.Body).Decode(&booking); err != nil {
        logger.LogError("Failed to decode request body", map[string]interface{}{
            "error": err.Error(),
            "path":  r.URL.Path,
        })
        http.Error(w, "Invalid request body", http.StatusBadRequest)
        return
    }

    // Create context for the request
    ctx := context.Background()

    // Call service layer to create booking
    err := service.CreateBookingService(ctx, &booking)
    if err != nil {
        logger.LogError("Failed to create booking", map[string]interface{}{
            "error":     err.Error(),
            "bookingId": booking.ID,
            "ownerId":   booking.OwnerID,
            "walkerId":  booking.WalkerID,
        })

        // Handle different types of errors
        switch {
        case strings.Contains(err.Error(), "invalid booking data"):
            http.Error(w, err.Error(), http.StatusBadRequest)
        case strings.Contains(err.Error(), "booking must be scheduled"):
            http.Error(w, err.Error(), http.StatusBadRequest)
        default:
            http.Error(w, "Internal server error", http.StatusInternalServerError)
        }
        return
    }

    // Log successful booking creation
    logger.LogInfo("Booking created successfully", map[string]interface{}{
        "bookingId": booking.ID,
        "ownerId":   booking.OwnerID,
        "walkerId":  booking.WalkerID,
    })

    // Return success response
    w.WriteHeader(http.StatusCreated)
    json.NewEncoder(w).Encode(map[string]interface{}{
        "success": true,
        "message": "Booking created successfully",
        "data":    booking,
    })
}

// GetBookingHandler handles HTTP GET requests to retrieve a booking by ID
// Addresses requirement: Technical Specification/1.3 Scope/Core Features/Booking System
// Handles booking management and retrieval
func GetBookingHandler(w http.ResponseWriter, r *http.Request) {
    // Set response content type
    w.Header().Set("Content-Type", "application/json")

    // Extract booking ID from URL path
    // Expected format: /bookings/{id}
    pathParts := strings.Split(r.URL.Path, "/")
    if len(pathParts) < 3 {
        http.Error(w, "Invalid request path", http.StatusBadRequest)
        return
    }
    bookingID := pathParts[len(pathParts)-1]

    // Validate booking ID
    if bookingID == "" {
        http.Error(w, "Booking ID is required", http.StatusBadRequest)
        return
    }

    // Create context for the request
    ctx := context.Background()

    // Call service layer to retrieve booking
    booking, err := service.GetBookingService(ctx, bookingID)
    if err != nil {
        logger.LogError("Failed to retrieve booking", map[string]interface{}{
            "error":     err.Error(),
            "bookingId": bookingID,
        })

        // Handle different types of errors
        switch {
        case strings.Contains(err.Error(), "booking not found"):
            http.Error(w, fmt.Sprintf("Booking not found with id: %s", bookingID), http.StatusNotFound)
        default:
            http.Error(w, "Internal server error", http.StatusInternalServerError)
        }
        return
    }

    // Log successful booking retrieval
    logger.LogInfo("Booking retrieved successfully", map[string]interface{}{
        "bookingId": bookingID,
        "ownerId":   booking.OwnerID,
        "walkerId":  booking.WalkerID,
    })

    // Return success response
    w.WriteHeader(http.StatusOK)
    json.NewEncoder(w).Encode(map[string]interface{}{
        "success": true,
        "data":    booking,
    })
}