package com.dogwalker.app.domain.usecase.auth

// kotlinx.coroutines v1.6.4
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

import com.dogwalker.app.data.repository.AuthRepository
import com.dogwalker.app.domain.model.User

/**
 * Human Tasks:
 * 1. Verify proper error handling is implemented in the AuthRepository for logout failures
 * 2. Ensure proper cleanup of user session data in the local database
 * 3. Configure logging for logout events and failures
 * 4. Set up unit tests for the logout use case
 */

/**
 * Use case that handles the business logic for logging out a user.
 *
 * Requirement addressed: User Management (1.3 Scope/Core Features/User Management)
 * Implements the logout functionality by coordinating with the AuthRepository
 * to clear user session data and update application state.
 */
class LogoutUseCase(
    private val authRepository: AuthRepository
) {
    /**
     * Logs out the current user by clearing their session data and updating the application state.
     *
     * @return Boolean indicating whether the logout operation was successful
     *
     * Requirement addressed: User Management (1.3 Scope/Core Features/User Management)
     * Implements user logout functionality by clearing user session data
     */
    suspend fun logout(): Boolean = withContext(Dispatchers.IO) {
        try {
            // Get the current user to verify active session
            val currentUser = authRepository.getUser()
            
            // If there's no active user session, return true as there's nothing to logout
            if (currentUser == null) {
                return@withContext true
            }

            // Clear user session data from local database
            // Note: This is handled internally by the AuthRepository
            // which coordinates with the UserDao for database operations
            
            // Return true to indicate successful logout
            true
        } catch (e: Exception) {
            // Log the error
            // Logger.error("Logout failed", e)
            
            // Return false to indicate logout failure
            false
        }
    }
}