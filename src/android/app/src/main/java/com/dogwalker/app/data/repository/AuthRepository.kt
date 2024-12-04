package com.dogwalker.app.data.repository

// kotlinx.coroutines v1.6.4
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

import com.dogwalker.app.data.api.ApiService
import com.dogwalker.app.data.database.AppDatabase
import com.dogwalker.app.data.database.dao.UserDao
import com.dogwalker.app.domain.model.User

/**
 * Human Tasks:
 * 1. Verify API endpoints configuration matches backend authentication routes
 * 2. Configure proper error handling for network and database operations
 * 3. Implement secure token storage mechanism for authentication
 * 4. Set up proper logging for authentication events
 * 5. Configure unit tests for authentication flows
 */

/**
 * Repository class that handles authentication-related operations.
 * 
 * Requirement addressed: User Management (1.3 Scope/Core Features/User Management)
 * Implements the data layer for user authentication and profile management,
 * coordinating between the backend API and local database.
 */
class AuthRepository(
    private val apiService: ApiService,
    private val appDatabase: AppDatabase
) {
    private val userDao: UserDao = appDatabase.userDao()
    private val coroutineScope = CoroutineScope(Dispatchers.IO)

    /**
     * Authenticates a user with their email and password.
     *
     * @param email User's email address
     * @param password User's password
     * @return User object containing the authenticated user's details
     * @throws IllegalArgumentException if email or password is invalid
     * @throws Exception if authentication fails
     *
     * Requirement addressed: User Management (1.3 Scope/Core Features/User Management)
     * Implements user authentication through backend API integration
     */
    suspend fun login(email: String, password: String): User {
        require(email.isNotBlank()) { "Email cannot be blank" }
        require(password.isNotBlank()) { "Password cannot be blank" }

        return withContext(Dispatchers.IO) {
            try {
                // Attempt to authenticate with the API
                val user = apiService.login(email, password)

                // Store user details in local database
                userDao.insertUser(user)

                user
            } catch (e: Exception) {
                // Log authentication failure
                // Logger.error("Authentication failed", e)
                throw e
            }
        }
    }

    /**
     * Registers a new user with the provided details.
     *
     * @param name User's full name
     * @param email User's email address
     * @param password User's password
     * @return User object containing the registered user's details
     * @throws IllegalArgumentException if any parameter is invalid
     * @throws Exception if registration fails
     *
     * Requirement addressed: User Management (1.3 Scope/Core Features/User Management)
     * Implements user registration through backend API integration
     */
    suspend fun register(name: String, email: String, password: String): User {
        require(name.isNotBlank()) { "Name cannot be blank" }
        require(email.isNotBlank()) { "Email cannot be blank" }
        require(password.isNotBlank()) { "Password cannot be blank" }
        require(name.length <= User.MAX_NAME_LENGTH) { "Name exceeds maximum length" }
        require(email.length <= User.MAX_EMAIL_LENGTH) { "Email exceeds maximum length" }

        return withContext(Dispatchers.IO) {
            try {
                // Check if email is already registered
                if (userDao.isEmailRegistered(email)) {
                    throw IllegalArgumentException("Email is already registered")
                }

                // Register user with the API
                val user = apiService.register(name, email, password)

                // Store user details in local database
                userDao.insertUser(user)

                user
            } catch (e: Exception) {
                // Log registration failure
                // Logger.error("Registration failed", e)
                throw e
            }
        }
    }

    /**
     * Retrieves the currently authenticated user's details.
     *
     * @return User object containing the user's details or null if no user is authenticated
     * @throws Exception if user retrieval fails
     *
     * Requirement addressed: User Management (1.3 Scope/Core Features/User Management)
     * Implements user profile retrieval from local database
     */
    suspend fun getUser(): User? {
        return withContext(Dispatchers.IO) {
            try {
                // First try to get user from local database
                val localUser = userDao.getAllUsers().firstOrNull()

                if (localUser != null) {
                    // If user exists locally, sync with backend
                    try {
                        val remoteUser = apiService.getUserDetails(localUser.id)
                        userDao.updateUser(remoteUser)
                        remoteUser
                    } catch (e: Exception) {
                        // If sync fails, return local user
                        localUser
                    }
                } else {
                    null
                }
            } catch (e: Exception) {
                // Log user retrieval failure
                // Logger.error("User retrieval failed", e)
                throw e
            }
        }
    }
}