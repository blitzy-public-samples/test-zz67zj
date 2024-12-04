package com.dogwalker.app.domain.usecase.walk

import com.dogwalker.app.domain.model.Walk
import com.dogwalker.app.domain.model.Location
import com.dogwalker.app.data.repository.WalkRepository
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.UUID

/**
 * Human Tasks:
 * 1. Verify that the database schema supports all Walk entity fields
 * 2. Ensure proper error handling is implemented in the UI layer for walk initiation failures
 * 3. Configure location permission handling in the app for tracking walk locations
 * 4. Set up proper monitoring for walk session tracking and completion
 */

/**
 * Use case responsible for initiating a new walk session.
 * 
 * Requirements addressed:
 * - Service Execution (1.3 Scope/Core Features/Service Execution)
 *   Handles the initiation of a walk session, including creating a new Walk entity
 *   and persisting it in the database.
 */
class StartWalkUseCase(
    private val walkRepository: WalkRepository
) {
    /**
     * Initiates a new walk session by creating a Walk entity and persisting it in the database.
     *
     * Requirements addressed:
     * - Service Execution (1.3 Scope/Core Features/Service Execution)
     *   Creates and persists a new walk session with initial location tracking.
     *
     * @param userId ID of the walker initiating the walk
     * @param dogId ID of the dog being walked
     * @param bookingId ID of the associated booking
     * @param initialLocation Initial GPS location of the walk
     * @return The newly created Walk entity
     * @throws IllegalArgumentException if any of the input parameters are invalid
     */
    suspend fun startWalk(
        userId: String,
        dogId: String,
        bookingId: String,
        initialLocation: Location
    ): Walk {
        // Validate input parameters
        require(userId.isNotBlank()) { "User ID cannot be blank" }
        require(dogId.isNotBlank()) { "Dog ID cannot be blank" }
        require(bookingId.isNotBlank()) { "Booking ID cannot be blank" }
        validateLocation(initialLocation)

        // Generate a unique ID for the new walk
        val walkId = UUID.randomUUID().toString()

        // Set the current timestamp as the start time
        val currentTime = SimpleDateFormat(Walk.DATE_FORMAT, Locale.getDefault())
            .format(Date())

        // Create a new Walk object
        val walk = Walk(
            id = walkId,
            userId = userId,
            dogId = dogId,
            bookingId = bookingId,
            locations = listOf(initialLocation),
            startTime = currentTime,
            endTime = currentTime, // Will be updated when walk ends
            status = "in_progress"
        )

        // Persist the Walk entity in the database
        walkRepository.insertWalk(walk)

        return walk
    }

    /**
     * Validates the location data to ensure it contains valid coordinates.
     *
     * @param location The location to validate
     * @throws IllegalArgumentException if the location coordinates are invalid
     */
    private fun validateLocation(location: Location) {
        require(location.id.isNotBlank()) { "Location ID cannot be blank" }
        require(location.latitude in -90.0..90.0) { 
            "Latitude must be between -90 and 90 degrees" 
        }
        require(location.longitude in -180.0..180.0) { 
            "Longitude must be between -180 and 180 degrees" 
        }
    }
}