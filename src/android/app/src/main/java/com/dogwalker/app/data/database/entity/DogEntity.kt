package com.dogwalker.app.data.database.entity

import androidx.room.ColumnInfo // Room version: 2.5.0
import androidx.room.Entity // Room version: 2.5.0
import androidx.room.PrimaryKey // Room version: 2.5.0
import com.dogwalker.app.domain.model.Dog

/**
 * Human Tasks:
 * 1. Verify database indices are properly created for optimal query performance
 * 2. Ensure Room schema version is properly managed in the database configuration
 * 3. Configure type converters for List<String> if not already set up in the database
 * 4. Verify foreign key constraints with owner table if applicable
 */

/**
 * Represents the database entity for storing dog-related data.
 * 
 * Requirements addressed:
 * - Dog Profile Management (1.3 Scope/Core Features/User Management)
 *   Handles the persistence and retrieval of dog profiles in the database
 *   by defining the database schema and mapping to the domain model.
 */
@Entity(tableName = "dogs")
data class DogEntity(
    @PrimaryKey
    @ColumnInfo(name = "id")
    val id: String,

    @ColumnInfo(name = "name")
    val name: String,

    @ColumnInfo(name = "breed")
    val breed: String,

    @ColumnInfo(name = "age")
    val age: Int,

    @ColumnInfo(name = "owner_id")
    val ownerId: String,

    @ColumnInfo(name = "walk_ids")
    val walkIds: List<String>
) {
    /**
     * Extension function to convert DogEntity to domain model Dog
     */
    fun toDog(): Dog = Dog(
        id = id,
        name = name,
        breed = breed,
        age = age,
        ownerId = ownerId,
        walkIds = walkIds
    )

    companion object {
        /**
         * Extension function to convert domain model Dog to DogEntity
         */
        fun fromDog(dog: Dog): DogEntity = DogEntity(
            id = dog.id,
            name = dog.name,
            breed = dog.breed,
            age = dog.age,
            ownerId = dog.ownerId,
            walkIds = dog.walkIds
        )
    }
}