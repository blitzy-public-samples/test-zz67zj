// Package test provides unit tests for the tracking-service components
package test

import (
	"testing"
	"time"
	"encoding/json"

	"github.com/stretchr/testify/assert" // v1.8.0
	"github.com/stretchr/testify/mock"   // v1.8.0
	"github.com/gorilla/websocket"       // v1.5.0

	"src/backend/tracking-service/internal/config"
	"src/backend/tracking-service/internal/models"
	"src/backend/tracking-service/internal/repository"
	"src/backend/tracking-service/internal/service"
	"src/backend/tracking-service/internal/websocket"
)

// Human Tasks:
// 1. Ensure MongoDB test instance is available and configured
// 2. Configure test environment variables:
//    - TRACKING_DB_URI: MongoDB test instance connection string
//    - TRACKING_WS_PORT: Test WebSocket port (e.g., 8081)
// 3. Set up test data cleanup procedures
// 4. Configure test coverage reporting

// MockMongoCollection mocks MongoDB collection operations
type MockMongoCollection struct {
	mock.Mock
}

func (m *MockMongoCollection) InsertOne(location models.Location) error {
	args := m.Called(location)
	return args.Error(0)
}

func (m *MockMongoCollection) Find(startTime, endTime time.Time) ([]models.Location, error) {
	args := m.Called(startTime, endTime)
	return args.Get(0).([]models.Location), args.Error(1)
}

// TestInsertLocation tests the InsertLocation function
// Addresses requirement: Real-time location tracking
// Location: 1.2 System Overview/High-Level Description/Backend Services
func TestInsertLocation(t *testing.T) {
	// Initialize mock collection
	mockCollection := new(MockMongoCollection)

	// Create test location data
	testLocation := models.Location{
		Latitude:  40.7128,
		Longitude: -74.0060,
		Timestamp: time.Now(),
	}

	// Set up mock expectations
	mockCollection.On("InsertOne", testLocation).Return(nil)

	// Test location insertion
	err := repository.InsertLocation(testLocation)

	// Assert expectations
	assert.NoError(t, err, "InsertLocation should not return an error")
	mockCollection.AssertExpectations(t)
}

// TestFindLocationsByTimeRange tests the FindLocationsByTimeRange function
// Addresses requirement: Real-time location tracking
// Location: 1.2 System Overview/High-Level Description/Backend Services
func TestFindLocationsByTimeRange(t *testing.T) {
	// Initialize mock collection
	mockCollection := new(MockMongoCollection)

	// Create test time range
	endTime := time.Now()
	startTime := endTime.Add(-1 * time.Hour)

	// Create expected location data
	expectedLocations := []models.Location{
		{
			Latitude:  40.7128,
			Longitude: -74.0060,
			Timestamp: startTime.Add(15 * time.Minute),
		},
		{
			Latitude:  40.7129,
			Longitude: -74.0061,
			Timestamp: startTime.Add(30 * time.Minute),
		},
	}

	// Set up mock expectations
	mockCollection.On("Find", startTime, endTime).Return(expectedLocations, nil)

	// Test location retrieval
	locations, err := repository.FindLocationsByTimeRange(startTime, endTime)

	// Assert expectations
	assert.NoError(t, err, "FindLocationsByTimeRange should not return an error")
	assert.Equal(t, expectedLocations, locations, "Retrieved locations should match expected data")
	mockCollection.AssertExpectations(t)
}

// TestWebSocketBroadcast tests the WebSocket hub's broadcasting functionality
// Addresses requirement: Scalable microservices architecture
// Location: 7.3 Technical Decisions/Architecture Patterns/Microservices
func TestWebSocketBroadcast(t *testing.T) {
	// Initialize WebSocket hub
	hub := websocket.NewHub()
	go hub.Run()

	// Create mock WebSocket connections
	mockConn1 := &websocket.Conn{}
	mockConn2 := &websocket.Conn{}

	// Register mock connections
	hub.Register <- mockConn1
	hub.Register <- mockConn2

	// Create test message
	testLocation := models.Location{
		Latitude:  40.7128,
		Longitude: -74.0060,
		Timestamp: time.Now(),
	}
	locationJSON, err := json.Marshal(testLocation)
	assert.NoError(t, err, "Failed to marshal test location")

	// Broadcast test message
	hub.BroadcastMessage(string(locationJSON))

	// Allow time for message processing
	time.Sleep(100 * time.Millisecond)

	// Assert hub state
	assert.Equal(t, 2, hub.GetConnectedClients(), "Hub should have 2 connected clients")
}

// TestTrackLocation tests the TrackLocation service function
// Addresses requirement: Real-time location tracking
// Location: 1.2 System Overview/High-Level Description/Backend Services
func TestTrackLocation(t *testing.T) {
	// Create test location
	testLocation := models.Location{
		Latitude:  40.7128,
		Longitude: -74.0060,
		Timestamp: time.Now(),
	}

	// Initialize mock dependencies
	mockCollection := new(MockMongoCollection)
	mockCollection.On("InsertOne", testLocation).Return(nil)

	// Test location tracking
	err := service.TrackLocation(testLocation)

	// Assert expectations
	assert.NoError(t, err, "TrackLocation should not return an error")
	mockCollection.AssertExpectations(t)
}

// TestGetLocationHistory tests the GetLocationHistory service function
// Addresses requirement: Real-time location tracking
// Location: 1.2 System Overview/High-Level Description/Backend Services
func TestGetLocationHistory(t *testing.T) {
	// Create test time range
	endTime := time.Now()
	startTime := endTime.Add(-1 * time.Hour)

	// Create expected location data
	expectedLocations := []models.Location{
		{
			Latitude:  40.7128,
			Longitude: -74.0060,
			Timestamp: startTime.Add(15 * time.Minute),
		},
		{
			Latitude:  40.7129,
			Longitude: -74.0061,
			Timestamp: startTime.Add(30 * time.Minute),
		},
	}

	// Initialize mock dependencies
	mockCollection := new(MockMongoCollection)
	mockCollection.On("Find", startTime, endTime).Return(expectedLocations, nil)

	// Test location history retrieval
	locations, err := service.GetLocationHistory(startTime, endTime)

	// Assert expectations
	assert.NoError(t, err, "GetLocationHistory should not return an error")
	assert.Equal(t, expectedLocations, locations, "Retrieved locations should match expected data")
	mockCollection.AssertExpectations(t)
}

// TestInvalidTimeRange tests error handling for invalid time ranges
func TestInvalidTimeRange(t *testing.T) {
	// Test case: end time before start time
	endTime := time.Now()
	startTime := endTime.Add(1 * time.Hour)

	locations, err := service.GetLocationHistory(startTime, endTime)

	assert.Error(t, err, "GetLocationHistory should return an error for invalid time range")
	assert.Nil(t, locations, "No locations should be returned for invalid time range")
}