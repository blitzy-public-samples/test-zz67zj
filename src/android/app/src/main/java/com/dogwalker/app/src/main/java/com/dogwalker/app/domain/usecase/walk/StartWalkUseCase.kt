package com.dogwalker.app.domain.usecase.walk

import com.dogwalker.app.data.repository.WalkRepository
import com.dogwalker.app.domain.model.Walk
import com.dogwalker.app.domain.model.Location
import java.time.Instant
import java.time.format.DateTimeFormatter
import java.util.UUID

/**
 * Human Tasks:
 * 1. Verify that the database schema supports the Walk entity structure
 * 2. Ensure proper error handling is implemented in the UI layer for walk initiation failures
 * 3. Configure location services permissions in the Android Manifest
 * 4. Set up proper monitoring for walk initiation success/failure rates
 */

/**
 * Use case class that handles the business logic for initiating a new walk.
 * 
 * Requirements addressed:
 * - Service Execution (1.3 Scope/Core Features/Service Execution)
 *   Implements the core functionality for starting a walk session, including
 *   creating the walk entity, persisting it, and initializing GPS tracking.
 */
class StartWalkUseCase(
    private val walkRepository: WalkRepository
) {
    /**
     * Initiates a new walk by creating a Walk entity and persisting it in the database.
     * 
     * Requirements addressed:
     * - Service Execution (1.3 Scope/Core Features/Service Execution)
     *   Handles the initiation of a walk, including creating a Walk entity,
     *   persisting it, and starting live GPS tracking.
     *
     * @param userId ID of the user (walker) initiating the walk
     * @param dogId ID of the dog being walked
     * @param bookingId ID of the associated booking
     * @param initialLocation Initial GPS location where the walk starts
     * @return The newly created Walk entity
     * @throws IllegalArgumentException if any of the required parameters are invalid
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
        require(initialLocation.latitude in -90.0..90.0) { "Invalid latitude value" }
        require(initialLocation.longitude in -180.0..180.0) { "Invalid longitude value" }

        // Generate a unique ID for the new walk
        val walkId = UUID.randomUUID().toString()

        // Get current timestamp in ISO 8601 format
        val currentTime = DateTimeFormatter.ISO_INSTANT.format(Instant.now())

        // Create the initial walk entity
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

        // Persist the walk entity in the database
        walkRepository.insertWalk(walk)

        return walk
    }
}