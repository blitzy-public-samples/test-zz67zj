package com.dogwalker.app.data.database.entity

// Room Database - version 2.5.0
import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.ColumnInfo
import com.dogwalker.app.domain.model.Location
import com.dogwalker.app.domain.model.Walk

/**
 * Human Tasks:
 * 1. Verify Room database configuration in app's build.gradle file (version 2.5.0)
 * 2. Ensure proper database migration strategy is in place when modifying entity structure
 * 3. Configure ProGuard rules to prevent obfuscation of this entity class if using R8/ProGuard
 * 4. Verify that the database indices are optimized for frequent queries on userId and dogId
 */

/**
 * Represents the database entity for storing walk details in the Dog Walker application.
 * 
 * Requirements addressed:
 * - Service Execution (1.3 Scope/Core Features/Service Execution)
 *   Implements the database entity for storing walk data including GPS tracking,
 *   route recording, and walk status information.
 */
@Entity(tableName = "walks")
data class WalkEntity(
    @PrimaryKey
    @ColumnInfo(name = "id")
    val id: String,

    @ColumnInfo(name = "user_id")
    val userId: String,

    @ColumnInfo(name = "dog_id")
    val dogId: String,

    @ColumnInfo(name = "booking_id")
    val bookingId: String,

    @ColumnInfo(name = "locations")
    val locations: List<Location>,

    @ColumnInfo(name = "start_time")
    val startTime: String,

    @ColumnInfo(name = "end_time")
    val endTime: String,

    @ColumnInfo(name = "status")
    val status: String
) {
    /**
     * Converts this database entity to a domain model Walk object.
     * 
     * @return Walk domain model object with all properties mapped from this entity
     */
    fun toDomainModel() = Walk(
        id = id,
        userId = userId,
        dogId = dogId,
        bookingId = bookingId,
        locations = locations,
        startTime = startTime,
        endTime = endTime,
        status = status
    )

    companion object {
        /**
         * Creates a WalkEntity from a domain model Walk object.
         * 
         * @param walk The Walk domain model object to convert
         * @return WalkEntity object with all properties mapped from the domain model
         */
        fun fromDomainModel(walk: Walk) = WalkEntity(
            id = walk.id,
            userId = walk.userId,
            dogId = walk.dogId,
            bookingId = walk.bookingId,
            locations = walk.locations,
            startTime = walk.startTime,
            endTime = walk.endTime,
            status = walk.status
        )

        /**
         * Valid walk status values, matching the domain model
         */
        val VALID_STATUSES = setOf(
            "scheduled",
            "in_progress",
            "completed",
            "cancelled",
            "paused"
        )
    }

    init {
        require(id.isNotBlank()) { "Walk ID cannot be blank" }
        require(userId.isNotBlank()) { "User ID cannot be blank" }
        require(dogId.isNotBlank()) { "Dog ID cannot be blank" }
        require(bookingId.isNotBlank()) { "Booking ID cannot be blank" }
        require(startTime.isNotBlank()) { "Start time cannot be blank" }
        require(endTime.isNotBlank()) { "End time cannot be blank" }
        require(status in VALID_STATUSES) { "Invalid walk status: $status" }
    }
}