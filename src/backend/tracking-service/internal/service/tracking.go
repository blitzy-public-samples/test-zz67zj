// Package service implements the core business logic for the tracking-service
// Version: 1.0.0

package service

import (
	"encoding/json"
	"fmt"
	"log"
	"time"

	"src/backend/tracking-service/internal/models"
	"src/backend/tracking-service/internal/repository"
	"src/backend/tracking-service/internal/websocket"
)

// Human Tasks:
// 1. Configure monitoring for location tracking latency
// 2. Set up alerts for high error rates in location processing
// 3. Review and adjust location validation thresholds
// 4. Ensure proper error handling and logging configuration
// 5. Verify WebSocket broadcast performance under load

// TrackLocation processes and broadcasts incoming location data
// Addresses requirement: Real-time location tracking
// Location: 1.2 System Overview/High-Level Description/Backend Services
func TrackLocation(location models.Location) error {
	// Validate the incoming location data
	if err := location.Validate(); err != nil {
		log.Printf("Location validation failed: %v", err)
		return fmt.Errorf("invalid location data: %w", err)
	}

	// Store the location data in MongoDB
	if err := repository.InsertLocation(location); err != nil {
		log.Printf("Failed to store location: %v", err)
		return fmt.Errorf("failed to store location: %w", err)
	}

	// Prepare location data for broadcasting
	locationJSON, err := json.Marshal(struct {
		Latitude  float64   `json:"latitude"`
		Longitude float64   `json:"longitude"`
		Timestamp time.Time `json:"timestamp"`
	}{
		Latitude:  location.Latitude,
		Longitude: location.Longitude,
		Timestamp: location.Timestamp,
	})
	if err != nil {
		log.Printf("Failed to marshal location data: %v", err)
		return fmt.Errorf("failed to marshal location data: %w", err)
	}

	// Broadcast location update to connected clients
	hub := websocket.NewHub()
	hub.BroadcastMessage(string(locationJSON))

	log.Printf("Location processed and broadcasted successfully: lat=%f, lon=%f, time=%v",
		location.Latitude, location.Longitude, location.Timestamp)

	return nil
}

// GetLocationHistory retrieves historical location data for analysis or display
// Addresses requirement: Scalable microservices architecture
// Location: 7.3 Technical Decisions/Architecture Patterns/Microservices
func GetLocationHistory(startTime, endTime time.Time) ([]models.Location, error) {
	// Validate time range parameters
	if startTime.IsZero() || endTime.IsZero() {
		return nil, fmt.Errorf("invalid time range: start and end times must be provided")
	}

	if endTime.Before(startTime) {
		return nil, fmt.Errorf("invalid time range: end time must be after start time")
	}

	// Maximum time range limit (e.g., 24 hours) to prevent excessive data retrieval
	maxDuration := 24 * time.Hour
	if endTime.Sub(startTime) > maxDuration {
		return nil, fmt.Errorf("time range exceeds maximum allowed duration of %v", maxDuration)
	}

	// Retrieve location data from MongoDB
	locations, err := repository.FindLocationsByTimeRange(startTime, endTime)
	if err != nil {
		log.Printf("Failed to retrieve location history: %v", err)
		return nil, fmt.Errorf("failed to retrieve location history: %w", err)
	}

	log.Printf("Retrieved %d location records between %v and %v",
		len(locations), startTime, endTime)

	return locations, nil
}