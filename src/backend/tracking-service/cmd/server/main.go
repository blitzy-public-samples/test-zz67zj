// Package main provides the entry point for the tracking-service
// Version: 1.0.0

package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"

	"src/backend/tracking-service/internal/config"
	"src/backend/tracking-service/internal/handlers"
	"src/backend/tracking-service/internal/repository"
	"src/backend/tracking-service/internal/websocket"
)

// Human Tasks:
// 1. Ensure all required environment variables are set in deployment configuration:
//    - TRACKING_DB_URI: MongoDB connection string
//    - TRACKING_WS_PORT: WebSocket server port
// 2. Configure monitoring and alerting for service health metrics
// 3. Set up proper logging infrastructure in production environment
// 4. Review and adjust server timeouts based on production requirements
// 5. Configure appropriate security measures (TLS, CORS, etc.)

func main() {
	// Initialize logging
	log.SetFlags(log.LstdFlags | log.Lshortfile)
	log.Printf("Starting tracking-service...")

	// Load configuration
	// Addresses requirement: Scalable microservices architecture
	// Location: 7.3 Technical Decisions/Architecture Patterns/Microservices
	cfg := config.LoadConfig()

	// Initialize MongoDB connection
	if err := repository.Initialize(cfg); err != nil {
		log.Fatalf("Failed to initialize MongoDB: %v", err)
	}
	defer repository.Close()

	// Initialize WebSocket hub
	// Addresses requirement: Real-time location tracking
	// Location: 1.2 System Overview/High-Level Description/Backend Services
	hub := websocket.NewHub()
	go hub.Run()

	// Set up HTTP routes
	mux := http.NewServeMux()

	// Register tracking endpoints
	mux.HandleFunc("/api/v1/location/track", handlers.TrackLocationHandler)
	mux.HandleFunc("/api/v1/location/history", handlers.GetLocationHistoryHandler)

	// Create server with configured timeouts
	server := &http.Server{
		Addr:         fmt.Sprintf(":%d", cfg.WebSocketPort),
		Handler:      mux,
		ReadTimeout:  30,  // Adjust based on requirements
		WriteTimeout: 30,  // Adjust based on requirements
		IdleTimeout:  120, // Adjust based on requirements
	}

	// Start server in a goroutine
	go func() {
		log.Printf("Starting HTTP server on port %d", cfg.WebSocketPort)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Failed to start server: %v", err)
		}
	}()

	// Set up graceful shutdown
	stop := make(chan os.Signal, 1)
	signal.Notify(stop, os.Interrupt, syscall.SIGTERM)

	// Wait for shutdown signal
	<-stop
	log.Printf("Shutting down server...")

	// Close all WebSocket connections
	hub.CloseAllConnections()

	// Close MongoDB connection
	if err := repository.Close(); err != nil {
		log.Printf("Error closing MongoDB connection: %v", err)
	}

	log.Printf("Server shutdown complete")
}