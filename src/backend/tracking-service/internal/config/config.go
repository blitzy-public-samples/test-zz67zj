// Package config provides configuration management for the tracking-service
// Version: 1.0.0

package config

import (
	"fmt"
	"log"
	"os"
	"strconv"
)

// Config holds the configuration settings for the tracking-service
// Requirement: Scalable microservices architecture
// Location: 7.3 Technical Decisions/Architecture Patterns/Microservices
type Config struct {
	// DatabaseURI is the connection string for the MongoDB tracking database
	DatabaseURI string

	// WebSocketPort is the port number for the WebSocket server
	WebSocketPort int
}

// Human Tasks:
// 1. Ensure environment variables are set in deployment configuration:
//    - TRACKING_DB_URI: MongoDB connection string with proper credentials
//    - TRACKING_WS_PORT: WebSocket server port (default: 8080)
// 2. Verify MongoDB instance is accessible from the service's network
// 3. Configure firewall rules to allow WebSocket traffic on the specified port
// 4. Set up monitoring for the WebSocket server port health

// LoadConfig loads the configuration settings from environment variables
// Returns a Config struct populated with the loaded settings
func LoadConfig() Config {
	// Initialize config struct
	config := Config{}

	// Load DatabaseURI from environment variable
	dbURI := os.Getenv("TRACKING_DB_URI")
	if dbURI == "" {
		log.Fatal("TRACKING_DB_URI environment variable is required")
	}
	config.DatabaseURI = dbURI

	// Load WebSocketPort from environment variable with default fallback
	wsPort := os.Getenv("TRACKING_WS_PORT")
	if wsPort == "" {
		// Default to port 8080 if not specified
		config.WebSocketPort = 8080
		log.Printf("TRACKING_WS_PORT not set, defaulting to %d", config.WebSocketPort)
	} else {
		// Parse the port number from string to int
		port, err := strconv.Atoi(wsPort)
		if err != nil {
			log.Fatal(fmt.Sprintf("Invalid TRACKING_WS_PORT value: %s", wsPort))
		}
		
		// Validate port number range
		if port < 1024 || port > 65535 {
			log.Fatal(fmt.Sprintf("TRACKING_WS_PORT must be between 1024 and 65535, got: %d", port))
		}
		
		config.WebSocketPort = port
	}

	// Log the loaded configuration (excluding sensitive information)
	log.Printf("Configuration loaded - WebSocket Port: %d", config.WebSocketPort)
	// Note: DatabaseURI is intentionally not logged to prevent credential exposure

	return config
}