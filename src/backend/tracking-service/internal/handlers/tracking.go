// Package handlers implements HTTP handlers for the tracking-service
// Version: 1.0.0

package handlers

import (
	"encoding/json" // standard library
	"log"          // standard library
	"net/http"     // standard library
	"time"

	"src/backend/tracking-service/internal/config"
	"src/backend/tracking-service/internal/models"
	"src/backend/tracking-service/internal/service"
	"src/backend/tracking-service/internal/websocket"
)

// Human Tasks:
// 1. Configure rate limiting for the HTTP endpoints
// 2. Set up monitoring for handler response times
// 3. Configure appropriate CORS settings for production
// 4. Review and adjust request payload size limits
// 5. Ensure proper error monitoring and alerting

// locationRequest represents the incoming JSON payload for location tracking
type locationRequest struct {
	Latitude  float64   `json:"latitude"`
	Longitude float64   `json:"longitude"`
	Timestamp time.Time `json:"timestamp"`
}

// locationHistoryRequest represents the query parameters for retrieving location history
type locationHistoryRequest struct {
	StartTime time.Time `json:"start_time"`
	EndTime   time.Time `json:"end_time"`
}

// TrackLocationHandler handles HTTP POST requests for tracking real-time location data
// Addresses requirement: Real-time location tracking
// Location: 1.2 System Overview/High-Level Description/Backend Services
func TrackLocationHandler(w http.ResponseWriter, r *http.Request) {
	// Verify HTTP method
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// Parse JSON request body
	var req locationRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		log.Printf("Failed to decode request body: %v", err)
		http.Error(w, "Invalid request payload", http.StatusBadRequest)
		return
	}

	// Create location model from request
	location := models.Location{
		Latitude:  req.Latitude,
		Longitude: req.Longitude,
		Timestamp: req.Timestamp,
	}

	// Validate location data
	if err := location.Validate(); err != nil {
		log.Printf("Location validation failed: %v", err)
		http.Error(w, "Invalid location data", http.StatusBadRequest)
		return
	}

	// Process and broadcast location through service layer
	if err := service.TrackLocation(location); err != nil {
		log.Printf("Failed to track location: %v", err)
		http.Error(w, "Failed to process location data", http.StatusInternalServerError)
		return
	}

	// Send success response
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{
		"status":  "success",
		"message": "Location tracked successfully",
	})
}

// GetLocationHistoryHandler handles HTTP GET requests for retrieving historical location data
// Addresses requirement: Scalable microservices architecture
// Location: 7.3 Technical Decisions/Architecture Patterns/Microservices
func GetLocationHistoryHandler(w http.ResponseWriter, r *http.Request) {
	// Verify HTTP method
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// Parse query parameters
	startTimeStr := r.URL.Query().Get("start_time")
	endTimeStr := r.URL.Query().Get("end_time")

	if startTimeStr == "" || endTimeStr == "" {
		http.Error(w, "Missing required query parameters: start_time, end_time", http.StatusBadRequest)
		return
	}

	// Parse time parameters
	startTime, err := time.Parse(time.RFC3339, startTimeStr)
	if err != nil {
		http.Error(w, "Invalid start_time format. Expected RFC3339", http.StatusBadRequest)
		return
	}

	endTime, err := time.Parse(time.RFC3339, endTimeStr)
	if err != nil {
		http.Error(w, "Invalid end_time format. Expected RFC3339", http.StatusBadRequest)
		return
	}

	// Retrieve location history from service layer
	locations, err := service.GetLocationHistory(startTime, endTime)
	if err != nil {
		log.Printf("Failed to retrieve location history: %v", err)
		http.Error(w, "Failed to retrieve location history", http.StatusInternalServerError)
		return
	}

	// Set response headers
	w.Header().Set("Content-Type", "application/json")

	// Encode and send response
	if err := json.NewEncoder(w).Encode(locations); err != nil {
		log.Printf("Failed to encode response: %v", err)
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		return
	}
}

// setupWebSocket configures and starts the WebSocket hub for real-time location updates
// Addresses requirement: Real-time location tracking
// Location: 1.2 System Overview/High-Level Description/Backend Services
func setupWebSocket(cfg config.Config) *websocket.Hub {
	hub := websocket.NewHub()
	go hub.Run()
	return hub
}

// init initializes the handlers package
func init() {
	log.Printf("Initializing tracking handlers...")
}