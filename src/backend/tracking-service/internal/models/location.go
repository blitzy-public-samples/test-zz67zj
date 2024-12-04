// Package models provides data models for the tracking service
package models

import (
	"time"
)

// Human Tasks:
// 1. Ensure proper indexing for location data in the database
// 2. Configure monitoring for location data validation
// 3. Set up alerts for location tracking anomalies
// 4. Review and adjust location validation rules based on business requirements

// Location represents a geographical location with latitude, longitude, and timestamp.
// Addresses requirement: Technical Specification/7.2.1 Core Components/Tracking Service
// The Location model is used for real-time location tracking and processing.
type Location struct {
	// Latitude represents the geographical latitude coordinate
	Latitude float64 `json:"latitude" bson:"latitude"`

	// Longitude represents the geographical longitude coordinate
	Longitude float64 `json:"longitude" bson:"longitude"`

	// Timestamp represents when this location was recorded
	Timestamp time.Time `json:"timestamp" bson:"timestamp"`
}

// NewLocation creates a new Location instance with the provided coordinates and timestamp.
// Addresses requirement: Technical Specification/7.2.1 Core Components/Tracking Service
func NewLocation(latitude, longitude float64, timestamp time.Time) *Location {
	return &Location{
		Latitude:  latitude,
		Longitude: longitude,
		Timestamp: timestamp,
	}
}

// Validate performs validation checks on the Location instance.
// Addresses requirement: Technical Specification/7.2.1 Core Components/Tracking Service
func (l *Location) Validate() error {
	// Validate latitude range (-90 to 90)
	if l.Latitude < -90 || l.Latitude > 90 {
		return fmt.Errorf("invalid latitude: must be between -90 and 90")
	}

	// Validate longitude range (-180 to 180)
	if l.Longitude < -180 || l.Longitude > 180 {
		return fmt.Errorf("invalid longitude: must be between -180 and 180")
	}

	// Validate timestamp is not zero
	if l.Timestamp.IsZero() {
		return fmt.Errorf("invalid timestamp: cannot be zero")
	}

	// Validate timestamp is not in the future
	if l.Timestamp.After(time.Now()) {
		return fmt.Errorf("invalid timestamp: cannot be in the future")
	}

	return nil
}