package com.dogwalker.app.domain.usecase.auth

// kotlinx.coroutines v1.6.4
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

import com.dogwalker.app.data.repository.AuthRepository
import com.dogwalker.app.domain.model.User

/**
 * Human Tasks:
 * 1. Verify error handling strategy aligns with application-wide error handling policy
 * 2. Configure proper logging for registration events
 * 3. Ensure proper validation rules are implemented for registration fields
 * 4. Review security measures for password handling
 */

/**
 * Use case that encapsulates the business logic for user registration.
 *
 * Requirement addressed: User Management (1.3 Scope/Core Features/User Management)
 * Implements the registration logic by coordinating with the AuthRepository to
 * register new users and store their data securely.
 *
 * @property authRepository Repository that handles authentication-related operations
 */
class RegisterUseCase(
    private val authRepository: AuthRepository
) {
    /**
     * Executes the registration use case with the provided user details.
     *
     * @param name The full name of the user
     * @param email The email address of the user
     * @param password The password for the user account
     * @return User object containing the registered user's details
     * @throws IllegalArgumentException if any of the input parameters are invalid
     * @throws Exception if registration fails
     *
     * Requirement addressed: User Management (1.3 Scope/Core Features/User Management)
     * Implements user registration by validating input parameters and coordinating
     * with the AuthRepository to create new user accounts.
     */
    suspend fun execute(
        name: String,
        email: String,
        password: String
    ): User = withContext(Dispatchers.IO) {
        // Validate input parameters
        require(name.isNotBlank()) { "Name cannot be blank" }
        require(email.isNotBlank()) { "Email cannot be blank" }
        require(password.isNotBlank()) { "Password cannot be blank" }
        
        // Validate length constraints
        require(name.length <= User.MAX_NAME_LENGTH) { 
            "Name cannot exceed ${User.MAX_NAME_LENGTH} characters" 
        }
        require(email.length <= User.MAX_EMAIL_LENGTH) { 
            "Email cannot exceed ${User.MAX_EMAIL_LENGTH} characters" 
        }

        try {
            // Delegate registration to the AuthRepository
            authRepository.register(
                name = name,
                email = email,
                password = password
            )
        } catch (e: Exception) {
            // Re-throw the exception to be handled by the presentation layer
            throw e
        }
    }
}