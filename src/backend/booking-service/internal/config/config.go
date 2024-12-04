// Package config provides configuration management for the Booking Service
// Version: 1.0.0

package config

import (
	"fmt"
	"github.com/sirupsen/logrus" // v1.9.0
	"github.com/spf13/viper"     // v1.10.1
)

// Config holds the configuration settings for the Booking Service
// Addresses requirement 7.2.1: Booking System Initialization
type Config struct {
	// DatabaseURL is the connection string for the PostgreSQL database
	DatabaseURL string

	// ServicePort is the port number on which the service will listen
	ServicePort int
}

// Global configuration instance
var Config *Config

// LoadConfig loads the configuration settings from environment variables and config files.
// Returns an error if configuration loading fails.
// Addresses requirement 7.2.1: Booking System Initialization - Configuration Loading
func LoadConfig() error {
	var err error
	logger := logrus.New()

	// Initialize Viper instance
	v := viper.New()

	// Set configuration defaults
	v.SetDefault("database.url", "postgres://localhost:5432/booking_service")
	v.SetDefault("service.port", 8080)

	// Set configuration file settings
	v.SetConfigName("config")        // config file name without extension
	v.SetConfigType("yaml")          // config file type
	v.AddConfigPath("/etc/booking/") // production config path
	v.AddConfigPath(".")             // local config path

	// Enable environment variable support
	v.AutomaticEnv()
	v.SetEnvPrefix("BOOKING")
	v.BindEnv("database.url", "BOOKING_DATABASE_URL")
	v.BindEnv("service.port", "BOOKING_SERVICE_PORT")

	// Read configuration file
	if err = v.ReadInConfig(); err != nil {
		// It's okay if config file is not found, we'll use env vars and defaults
		if _, ok := err.(viper.ConfigFileNotFoundError); !ok {
			logger.WithError(err).Error("Failed to read config file")
			return fmt.Errorf("failed to read config file: %w", err)
		}
		logger.Info("No config file found, using environment variables and defaults")
	}

	// Create new Config instance
	Config = &Config{
		DatabaseURL: v.GetString("database.url"),
		ServicePort: v.GetInt("service.port"),
	}

	// Validate configuration
	if err = validateConfig(Config); err != nil {
		logger.WithError(err).Error("Configuration validation failed")
		return fmt.Errorf("configuration validation failed: %w", err)
	}

	logger.WithFields(logrus.Fields{
		"servicePort": Config.ServicePort,
		// Mask sensitive database URL
		"databaseConfigured": Config.DatabaseURL != "",
	}).Info("Configuration loaded successfully")

	return nil
}

// validateConfig performs validation checks on the configuration values
func validateConfig(cfg *Config) error {
	if cfg.DatabaseURL == "" {
		return fmt.Errorf("database URL is required")
	}

	if cfg.ServicePort < 1 || cfg.ServicePort > 65535 {
		return fmt.Errorf("service port must be between 1 and 65535")
	}

	return nil
}