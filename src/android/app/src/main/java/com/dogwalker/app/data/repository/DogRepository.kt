package com.dogwalker.app.data.repository

import com.dogwalker.app.data.database.AppDatabase
import com.dogwalker.app.data.database.dao.DogDao
import com.dogwalker.app.data.database.entity.DogEntity
import com.dogwalker.app.domain.model.Dog
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Human Tasks:
 * 1. Verify that Room database is properly initialized in the Application class
 * 2. Ensure proper error handling is implemented in the presentation layer
 * 3. Consider implementing caching strategy for frequently accessed dog profiles
 * 4. Set up database backup mechanism for dog profile data
 */

/**
 * Repository implementation for managing dog-related data operations.
 * 
 * Requirements addressed:
 * - Dog Profile Management (1.3 Scope/Core Features/User Management)
 *   Implements the data layer for managing dog profiles, providing methods
 *   for creating, retrieving, and deleting dog records in the database.
 *
 * @property dogDao Data Access Object for dog-related database operations
 */
@Singleton
class DogRepository @Inject constructor(
    private val appDatabase: AppDatabase
) {
    private val dogDao: DogDao = appDatabase.dogDao()

    /**
     * Retrieves all dog profiles from the database.
     * Converts the database entities to domain models before returning.
     *
     * Requirements addressed:
     * - Dog Profile Management (1.3 Scope/Core Features/User Management)
     *   Provides functionality to retrieve all dog profiles stored in the system.
     *
     * @return List of Dog domain models
     */
    suspend fun getAllDogs(): List<Dog> {
        return dogDao.getAllDogs().map { dogEntity ->
            dogEntity.toDog()
        }
    }

    /**
     * Adds a new dog profile to the database.
     * Converts the domain model to a database entity before insertion.
     *
     * Requirements addressed:
     * - Dog Profile Management (1.3 Scope/Core Features/User Management)
     *   Implements functionality to create new dog profiles in the system.
     *
     * @param dog The Dog domain model to be added
     */
    suspend fun addDog(dog: Dog) {
        val dogEntity = DogEntity.fromDog(dog)
        dogDao.insertDog(dogEntity)
    }

    /**
     * Deletes a dog profile from the database.
     * Converts the domain model to a database entity before deletion.
     *
     * Requirements addressed:
     * - Dog Profile Management (1.3 Scope/Core Features/User Management)
     *   Provides functionality to remove dog profiles from the system.
     *
     * @param dog The Dog domain model to be deleted
     */
    suspend fun deleteDog(dog: Dog) {
        val dogEntity = DogEntity.fromDog(dog)
        dogDao.deleteDog(dogEntity)
    }
}