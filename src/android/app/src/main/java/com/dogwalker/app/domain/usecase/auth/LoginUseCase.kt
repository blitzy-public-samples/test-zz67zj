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
 * 2. Configure proper logging for authentication events
 * 3. Ensure proper unit test coverage for authentication flows
 */

/**
 * Use case class that encapsulates the business logic for user authentication.
 *
 * Requirement addressed: User Management (1.3 Scope/Core Features/User Management)
 * Implements the domain layer logic for user authentication by coordinating with
 * the AuthRepository to verify credentials and retrieve user details.
 *
 * @property authRepository Repository handling authentication-related data operations
 */
class LoginUseCase(
    private val authRepository: AuthRepository
) {
    /**
     * Executes the login use case by authenticating the user with the provided credentials.
     *
     * @param email User's email address
     * @param password User's password
     * @return User object containing the authenticated user's details
     * @throws IllegalArgumentException if email or password is invalid
     * @throws Exception if authentication fails
     *
     * Requirement addressed: User Management (1.3 Scope/Core Features/User Management)
     * Implements user authentication by verifying credentials and retrieving user details
     */
    suspend fun execute(email: String, password: String): User {
        // Input validation
        require(email.isNotBlank()) { "Email cannot be blank" }
        require(password.isNotBlank()) { "Password cannot be blank" }
        require(email.length <= User.MAX_EMAIL_LENGTH) { "Email exceeds maximum length" }
        
        return withContext(Dispatchers.IO) {
            try {
                // Delegate authentication to repository
                authRepository.login(email, password)
            } catch (e: Exception) {
                // Rethrow the exception to be handled by the presentation layer
                throw e
            }
        }
    }
}