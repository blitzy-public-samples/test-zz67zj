package com.dogwalker.app.domain.usecase.walk

import com.dogwalker.app.data.repository.WalkRepository
import com.dogwalker.app.domain.model.Walk
import java.text.SimpleDateFormat
import java.util.Locale
import java.util.TimeUnit

/**
 * Human Tasks:
 * 1. Verify that the date format matches the API contract (yyyy-MM-dd'T'HH:mm:ss'Z')
 * 2. Ensure proper error handling is implemented in the UI layer for database operations
 * 3. Configure unit tests to cover all edge cases of walk duration calculation
 * 4. Verify that the walk status transitions are properly handled in the UI
 */

/**
 * Use case that handles the business logic for ending a walk session.
 * 
 * Requirements addressed:
 * - Service Execution (1.3 Scope/Core Features/Service Execution)
 *   Implements the completion of a walk session by updating the walk status,
 *   calculating the duration, and persisting the changes to the database.
 */
class EndWalkUseCase(
    private val walkRepository: WalkRepository
) {
    /**
     * Ends a walk by updating its status and persisting the changes.
     * 
     * Requirements addressed:
     * - Service Execution (1.3 Scope/Core Features/Service Execution)
     *   Handles the completion of a walk, including updating the walk status,
     *   calculating the duration, and persisting the changes.
     *
     * @param walkId The unique identifier of the walk to end
     * @param endTime The end time of the walk in ISO 8601 format (yyyy-MM-dd'T'HH:mm:ss'Z')
     * @return The updated Walk entity with the new status and duration
     * @throws IllegalArgumentException if the walkId is blank or endTime is invalid
     * @throws IllegalStateException if the walk is not found or already completed
     */
    suspend fun endWalk(walkId: String, endTime: String): Walk {
        // Validate input parameters
        require(walkId.isNotBlank()) { "Walk ID cannot be blank" }
        require(endTime.isNotBlank()) { "End time cannot be blank" }
        require(isValidDateFormat(endTime)) { "Invalid end time format. Expected format: yyyy-MM-dd'T'HH:mm:ss'Z'" }

        // Retrieve the walk from repository
        val walk = walkRepository.getWalkById(walkId)
            ?: throw IllegalStateException("Walk not found with ID: $walkId")

        // Validate walk state
        require(walk.status != "completed") { "Walk is already completed" }
        require(walk.status != "cancelled") { "Cannot end a cancelled walk" }
        
        // Validate end time is after start time
        val dateFormat = SimpleDateFormat(Walk.DATE_FORMAT, Locale.getDefault())
        val startTimeDate = dateFormat.parse(walk.startTime)
            ?: throw IllegalStateException("Invalid start time format in walk record")
        val endTimeDate = dateFormat.parse(endTime)
            ?: throw IllegalStateException("Invalid end time format")

        require(endTimeDate.after(startTimeDate)) { "End time must be after start time" }

        // Calculate walk duration in milliseconds
        val durationMillis = endTimeDate.time - startTimeDate.time
        val durationHours = TimeUnit.MILLISECONDS.toHours(durationMillis)

        // Validate walk duration
        require(durationHours <= Walk.MAX_DURATION_HOURS) { 
            "Walk duration exceeds maximum allowed time of ${Walk.MAX_DURATION_HOURS} hours" 
        }
        require(TimeUnit.MILLISECONDS.toMinutes(durationMillis) >= Walk.MIN_DURATION_MINUTES) {
            "Walk duration is less than minimum required time of ${Walk.MIN_DURATION_MINUTES} minutes"
        }

        // Create updated walk with completed status
        val updatedWalk = walk.copy(
            endTime = endTime,
            status = "completed"
        )

        // Persist the changes
        walkRepository.insertWalk(updatedWalk)

        return updatedWalk
    }

    /**
     * Validates that a date string matches the required ISO 8601 format.
     *
     * @param dateString The date string to validate
     * @return true if the date string is valid, false otherwise
     */
    private fun isValidDateFormat(dateString: String): Boolean {
        return try {
            SimpleDateFormat(Walk.DATE_FORMAT, Locale.getDefault()).parse(dateString) != null
        } catch (e: Exception) {
            false
        }
    }
}