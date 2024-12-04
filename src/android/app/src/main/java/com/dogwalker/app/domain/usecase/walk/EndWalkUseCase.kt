package com.dogwalker.app.domain.usecase.walk

import com.dogwalker.app.domain.model.Walk
import com.dogwalker.app.data.repository.WalkRepository
import java.text.SimpleDateFormat
import java.util.Locale

/**
 * Human Tasks:
 * 1. Verify that the date format matches the API contract for walk time fields
 * 2. Ensure proper error handling is implemented in the UI layer for failed walk completion
 * 3. Configure unit tests to verify walk duration calculations
 * 4. Verify that the walk status transitions are properly handled in the UI
 */

/**
 * Use case class that handles the business logic for ending a walk.
 * 
 * Requirements addressed:
 * - Service Execution (1.3 Scope/Core Features/Service Execution)
 *   Implements the business logic for completing a walk session, including
 *   updating the walk status, calculating duration, and persisting changes.
 */
class EndWalkUseCase(
    private val walkRepository: WalkRepository
) {
    /**
     * Ends a walk by updating its status, calculating the duration, and persisting the changes.
     *
     * Requirements addressed:
     * - Service Execution (1.3 Scope/Core Features/Service Execution)
     *   Handles the completion of a walk session by updating its status and
     *   recording the end time for duration calculation.
     *
     * @param walkId The unique identifier of the walk to end
     * @param endTime The end time of the walk in ISO 8601 format (yyyy-MM-dd'T'HH:mm:ss'Z')
     * @return The updated Walk entity after the walk has ended
     * @throws IllegalArgumentException if the walk ID is blank or the walk doesn't exist
     * @throws IllegalStateException if the walk is not in progress or the end time is invalid
     */
    suspend fun endWalk(walkId: String, endTime: String): Walk {
        // Validate input parameters
        require(walkId.isNotBlank()) { "Walk ID cannot be blank" }
        require(endTime.isNotBlank()) { "End time cannot be blank" }

        // Retrieve the walk from repository
        val walk = walkRepository.getWalkById(walkId)
            ?: throw IllegalArgumentException("Walk not found with ID: $walkId")

        // Validate walk status
        if (walk.status != "in_progress") {
            throw IllegalStateException("Cannot end walk that is not in progress. Current status: ${walk.status}")
        }

        // Validate end time
        val dateFormat = SimpleDateFormat(Walk.DATE_FORMAT, Locale.getDefault())
        val startTimeDate = dateFormat.parse(walk.startTime)
        val endTimeDate = dateFormat.parse(endTime)

        requireNotNull(startTimeDate) { "Invalid start time format" }
        requireNotNull(endTimeDate) { "Invalid end time format" }

        if (endTimeDate.before(startTimeDate)) {
            throw IllegalArgumentException("End time cannot be before start time")
        }

        // Calculate duration in hours
        val durationHours = (endTimeDate.time - startTimeDate.time) / (1000.0 * 60 * 60)
        
        // Validate duration constraints
        if (durationHours > Walk.MAX_DURATION_HOURS) {
            throw IllegalStateException("Walk duration exceeds maximum allowed time of ${Walk.MAX_DURATION_HOURS} hours")
        }

        if (durationHours * 60 < Walk.MIN_DURATION_MINUTES) {
            throw IllegalStateException("Walk duration is less than minimum required time of ${Walk.MIN_DURATION_MINUTES} minutes")
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
}