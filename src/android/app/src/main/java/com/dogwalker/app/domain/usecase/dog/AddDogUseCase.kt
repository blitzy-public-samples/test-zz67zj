package com.dogwalker.app.domain.usecase.dog

import com.dogwalker.app.data.repository.DogRepository
import com.dogwalker.app.domain.model.Dog
import javax.inject.Inject

/**
 * Human Tasks:
 * 1. Verify that DogRepository is properly configured in the dependency injection module
 * 2. Ensure proper error handling is implemented in the presentation layer when calling this use case
 * 3. Consider implementing unit tests to verify validation logic
 */

/**
 * Use case that encapsulates the business logic for adding a new dog profile to the system.
 * 
 * Requirements addressed:
 * - Dog Profile Management (1.3 Scope/Core Features/User Management)
 *   Implements the business logic for adding new dog profiles, ensuring proper
 *   data validation before persistence.
 *
 * @property dogRepository Repository for managing dog-related data operations
 */
class AddDogUseCase @Inject constructor(
    private val dogRepository: DogRepository
) {
    /**
     * Executes the use case to add a new dog profile.
     * Validates the dog data before persisting it to the repository.
     *
     * Requirements addressed:
     * - Dog Profile Management (1.3 Scope/Core Features/User Management)
     *   Handles the addition of new dog profiles with proper validation.
     *
     * @param dog The Dog object containing the profile information to be added
     * @throws IllegalArgumentException if any validation checks fail
     */
    suspend fun execute(dog: Dog) {
        // Validate required fields
        require(dog.id.isNotBlank()) { "Dog ID cannot be blank" }
        require(dog.name.isNotBlank()) { "Dog name cannot be blank" }
        require(dog.breed.isNotBlank()) { "Dog breed cannot be blank" }
        require(dog.ownerId.isNotBlank()) { "Owner ID cannot be blank" }

        // Validate name length
        require(dog.name.length <= Dog.MAX_NAME_LENGTH) {
            "Dog name cannot exceed ${Dog.MAX_NAME_LENGTH} characters"
        }

        // Validate age range
        require(dog.age in Dog.MIN_AGE..Dog.MAX_AGE) {
            "Dog age must be between ${Dog.MIN_AGE} and ${Dog.MAX_AGE} years"
        }

        // Persist the dog profile
        dogRepository.addDog(dog)
    }
}