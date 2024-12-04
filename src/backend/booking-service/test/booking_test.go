package test

import (
    "context"
    "testing"
    "time"

    "github.com/stretchr/testify/assert" // v1.8.0
    "github.com/stretchr/testify/mock"   // v1.8.0

    "src/backend/booking-service/internal/models"
    "src/backend/booking-service/internal/service"
    "src/backend/booking-service/internal/repository"
)

// MockRepository is a mock implementation of the repository layer
type MockRepository struct {
    mock.Mock
}

// CreateBooking mocks the repository's CreateBooking method
func (m *MockRepository) CreateBooking(ctx context.Context, booking *models.Booking) error {
    args := m.Called(ctx, booking)
    return args.Error(0)
}

// GetBookingByID mocks the repository's GetBookingByID method
func (m *MockRepository) GetBookingByID(ctx context.Context, id string) (*models.Booking, error) {
    args := m.Called(ctx, id)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).(*models.Booking), args.Error(1)
}

// TestCreateBookingService tests the CreateBookingService function
// Addresses requirement: Booking System Testing/7.2.1 Core Components/Booking Service
func TestCreateBookingService(t *testing.T) {
    // Set up mock repository
    mockRepo := new(MockRepository)
    repository.DB = nil // Ensure we're not using real DB

    // Create test booking data
    testBooking := &models.Booking{
        ID:          "test-booking-1",
        OwnerID:     "owner-1",
        WalkerID:    "walker-1",
        DogID:       "dog-1",
        ScheduledAt: time.Now().Add(24 * time.Hour), // Schedule for tomorrow
        Status:      models.BookingStatusPending,
        Amount:      50.00,
    }

    // Test case 1: Successful booking creation
    t.Run("Successful booking creation", func(t *testing.T) {
        // Set up mock expectations
        mockRepo.On("CreateBooking", mock.Anything, testBooking).Return(nil)

        // Call the service function
        err := service.CreateBookingService(context.Background(), testBooking)

        // Assert expectations
        assert.NoError(t, err)
        mockRepo.AssertExpectations(t)
    })

    // Test case 2: Invalid booking data
    t.Run("Invalid booking data", func(t *testing.T) {
        invalidBooking := &models.Booking{
            // Missing required fields
            ID:       "",
            OwnerID: "",
        }

        err := service.CreateBookingService(context.Background(), invalidBooking)

        assert.Error(t, err)
        assert.Contains(t, err.Error(), "invalid booking data")
    })

    // Test case 3: Past scheduled time
    t.Run("Past scheduled time", func(t *testing.T) {
        pastBooking := &models.Booking{
            ID:          "test-booking-2",
            OwnerID:     "owner-1",
            WalkerID:    "walker-1",
            DogID:       "dog-1",
            ScheduledAt: time.Now().Add(-24 * time.Hour), // Schedule for yesterday
            Status:      models.BookingStatusPending,
            Amount:      50.00,
        }

        err := service.CreateBookingService(context.Background(), pastBooking)

        assert.Error(t, err)
        assert.Contains(t, err.Error(), "must be scheduled for a future time")
    })
}

// TestGetBookingService tests the GetBookingService function
// Addresses requirement: Booking System Testing/7.2.1 Core Components/Booking Service
func TestGetBookingService(t *testing.T) {
    // Set up mock repository
    mockRepo := new(MockRepository)
    repository.DB = nil // Ensure we're not using real DB

    // Create test booking data
    testBooking := &models.Booking{
        ID:          "test-booking-1",
        OwnerID:     "owner-1",
        WalkerID:    "walker-1",
        DogID:       "dog-1",
        ScheduledAt: time.Now().Add(24 * time.Hour),
        Status:      models.BookingStatusPending,
        Amount:      50.00,
    }

    // Test case 1: Successful booking retrieval
    t.Run("Successful booking retrieval", func(t *testing.T) {
        // Set up mock expectations
        mockRepo.On("GetBookingByID", mock.Anything, testBooking.ID).Return(testBooking, nil)

        // Call the service function
        booking, err := service.GetBookingService(context.Background(), testBooking.ID)

        // Assert expectations
        assert.NoError(t, err)
        assert.NotNil(t, booking)
        assert.Equal(t, testBooking.ID, booking.ID)
        assert.Equal(t, testBooking.OwnerID, booking.OwnerID)
        mockRepo.AssertExpectations(t)
    })

    // Test case 2: Booking not found
    t.Run("Booking not found", func(t *testing.T) {
        nonExistentID := "non-existent-id"
        mockRepo.On("GetBookingByID", mock.Anything, nonExistentID).Return(nil, repository.ErrBookingNotFound)

        booking, err := service.GetBookingService(context.Background(), nonExistentID)

        assert.Error(t, err)
        assert.Nil(t, booking)
        assert.Contains(t, err.Error(), "booking not found")
    })

    // Test case 3: Empty booking ID
    t.Run("Empty booking ID", func(t *testing.T) {
        booking, err := service.GetBookingService(context.Background(), "")

        assert.Error(t, err)
        assert.Nil(t, booking)
        assert.Contains(t, err.Error(), "booking ID is required")
    })

    // Test case 4: Database error
    t.Run("Database error", func(t *testing.T) {
        mockRepo.On("GetBookingByID", mock.Anything, testBooking.ID).Return(nil, repository.ErrDatabaseError)

        booking, err := service.GetBookingService(context.Background(), testBooking.ID)

        assert.Error(t, err)
        assert.Nil(t, booking)
        assert.Contains(t, err.Error(), "failed to retrieve booking")
    })
}