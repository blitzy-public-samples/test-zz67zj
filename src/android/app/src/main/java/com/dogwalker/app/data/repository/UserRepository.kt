/**
 * Human Tasks:
 * 1. Verify proper error handling and logging is configured for database operations
 * 2. Ensure database operations are performed on the appropriate coroutine dispatcher
 * 3. Consider implementing caching strategy for frequently accessed user data
 * 4. Set up unit tests for repository methods with mock database
 */

package com.dogwalker.app.data.repository

import com.dogwalker.app.data.database.AppDatabase
import com.dogwalker.app.data.database.dao.UserDao
import com.dogwalker.app.domain.model.User

/**
 * Repository class that provides an abstraction layer for user-related data operations.
 * 
 * Requirements addressed:
 * - User Management (1.3 Scope/Core Features/User Management)
 *   Implements the data layer for managing user profiles by providing methods
 *   for creating, retrieving, updating, and deleting user data.
 */
class UserRepository(
    appDatabase: AppDatabase
) {
    private val userDao: UserDao = appDatabase.userDao()

    /**
     * Retrieves a user by their unique identifier.
     *
     * @param userId The unique identifier of the user to retrieve
     * @return The User object if found, null otherwise
     */
    suspend fun getUserById(userId: String): User? {
        return userDao.getUserById(userId)
    }

    /**
     * Inserts a new user into the database.
     * If a user with the same ID already exists, the operation will fail.
     *
     * @param user The User object to be inserted
     */
    suspend fun insertUser(user: User) {
        userDao.insertUser(user)
    }

    /**
     * Updates an existing user's information in the database.
     * If the user doesn't exist, the operation will fail.
     *
     * @param user The User object containing updated information
     */
    suspend fun updateUser(user: User) {
        userDao.updateUser(user)
    }

    /**
     * Deletes a user from the database.
     * If the user doesn't exist, the operation will fail.
     *
     * @param user The User object to be deleted
     */
    suspend fun deleteUser(user: User) {
        userDao.deleteUser(user)
    }
}