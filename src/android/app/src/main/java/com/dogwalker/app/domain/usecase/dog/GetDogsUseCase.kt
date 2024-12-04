package com.dogwalker.app.domain.usecase.dog

import com.dogwalker.app.data.repository.DogRepository
import com.dogwalker.app.domain.model.Dog
import javax.inject.Inject

/**
 * Human Tasks:
 * 1. Verify that DogRepository is properly injected through Dagger/Hilt dependency injection
 * 2. Ensure proper error handling is implemented in the presentation layer when calling this use case
 * 3. Consider implementing caching strategy if dog profiles are frequently accessed
 */

/**
 * Use case for retrieving all dog profiles from the repository.
 * 
 * Requirements addressed:
 * - Dog Profile Management (1.3 Scope/Core Features/User Management)
 *   Handles the retrieval of dog profiles for display and management in the application.
 *
 * @property dogRepository Repository instance for accessing dog-related data operations
 */
class GetDogsUseCase @Inject constructor(
    private val dogRepository: DogRepository
) {
    /**
     * Executes the use case to retrieve all dog profiles.
     * 
     * Requirements addressed:
     * - Dog Profile Management (1.3 Scope/Core Features/User Management)
     *   Retrieves all dog profiles from the repository for display in the application.
     *
     * @return List of Dog objects containing all dog profiles
     */
    suspend fun execute(): List<Dog> {
        return dogRepository.getAllDogs()
    }
}