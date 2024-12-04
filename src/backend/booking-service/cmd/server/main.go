// Package main is the entry point for the Booking Service
package main

import (
    "fmt"
    "log"
    "net/http"
    "os"
    "os/signal"
    "syscall"

    "src/backend/booking-service/internal/config"
    "src/backend/booking-service/internal/handlers"
    "src/backend/booking-service/internal/repository"
)

// Human Tasks:
// 1. Configure environment variables for service configuration
// 2. Set up monitoring and metrics collection
// 3. Configure logging aggregation
// 4. Set up health check endpoint monitoring
// 5. Review and adjust server timeouts based on load testing
// 6. Configure TLS/SSL certificates for HTTPS
// 7. Set up rate limiting and request throttling

func main() {
    // Initialize configuration
    // Addresses requirement 7.2.1: Booking System Initialization
    if err := config.LoadConfig(); err != nil {
        log.Fatalf("Failed to load configuration: %v", err)
    }

    // Initialize database connection
    // Addresses requirement 7.2.1: Booking System Initialization
    if err := repository.InitDB(config.Config); err != nil {
        log.Fatalf("Failed to initialize database: %v", err)
    }
    defer repository.Close()

    // Initialize router and register routes
    // Addresses requirement 7.2.1: Core Components/Booking Service
    router := http.NewServeMux()

    // Register booking endpoints
    router.HandleFunc("/api/v1/bookings", func(w http.ResponseWriter, r *http.Request) {
        switch r.Method {
        case http.MethodPost:
            handlers.CreateBookingHandler(w, r)
        case http.MethodGet:
            handlers.GetBookingHandler(w, r)
        default:
            http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
        }
    })

    // Configure server
    server := &http.Server{
        Addr:    fmt.Sprintf(":%d", config.Config.ServicePort),
        Handler: router,
    }

    // Start server in a goroutine
    go func() {
        log.Printf("Starting Booking Service on port %d", config.Config.ServicePort)
        if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            log.Fatalf("Failed to start server: %v", err)
        }
    }()

    // Set up graceful shutdown
    stop := make(chan os.Signal, 1)
    signal.Notify(stop, os.Interrupt, syscall.SIGTERM)

    // Wait for interrupt signal
    <-stop
    log.Println("Shutting down server...")

    // Close database connection
    if err := repository.Close(); err != nil {
        log.Printf("Error closing database connection: %v", err)
    }

    log.Println("Server shutdown complete")
}