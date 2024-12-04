/**
 * Human Tasks:
 * 1. Ensure proper database indexing is configured for optimal query performance
 * 2. Verify that the database migration strategy handles any schema changes
 * 3. Configure Room database testing with sample data
 * 4. Set up database backup and recovery procedures
 */

package com.dogwalker.app.data.database.dao

import androidx.room.Dao // Room version: 2.5.0
import androidx.room.Delete // Room version: 2.5.0
import androidx.room.Insert // Room version: 2.5.0
import androidx.room.Query // Room version: 2.5.0
import androidx.room.Update // Room version: 2.5.0
import com.dogwalker.app.domain.model.User

/**
 * Data Access Object (DAO) interface for User entity operations.
 * 
 * Requirements addressed:
 * - User Management (1.3 Scope/Core Features/User Management)
 *   Implements database operations for managing user profiles including
 *   creating, updating, retrieving, and deleting user data.
 */
@Dao
interface UserDao {
    /**
     * Retrieves a user from the database by their unique ID.
     *
     * @param userId The unique identifier of the user to retrieve
     * @return The User object if found, null otherwise
     */
    @Query("SELECT * FROM User WHERE id = :userId")
    suspend fun getUserById(userId: String): User?

    /**
     * Retrieves all users from the database.
     *
     * @return List of all users in the database
     */
    @Query("SELECT * FROM User")
    suspend fun getAllUsers(): List<User>

    /**
     * Retrieves a user from the database by their email address.
     *
     * @param email The email address of the user to retrieve
     * @return The User object if found, null otherwise
     */
    @Query("SELECT * FROM User WHERE email = :email")
    suspend fun getUserByEmail(email: String): User?

    /**
     * Retrieves a user from the database by their phone number.
     *
     * @param phoneNumber The phone number of the user to retrieve
     * @return The User object if found, null otherwise
     */
    @Query("SELECT * FROM User WHERE phoneNumber = :phoneNumber")
    suspend fun getUserByPhoneNumber(phoneNumber: String): User?

    /**
     * Inserts a new user into the database.
     * If a user with the same ID already exists, the transaction will fail.
     *
     * @param user The User object to insert
     */
    @Insert
    suspend fun insertUser(user: User)

    /**
     * Updates an existing user's information in the database.
     * If the user doesn't exist, the transaction will fail.
     *
     * @param user The User object containing updated information
     */
    @Update
    suspend fun updateUser(user: User)

    /**
     * Deletes a user from the database.
     * If the user doesn't exist, the transaction will fail.
     *
     * @param user The User object to delete
     */
    @Delete
    suspend fun deleteUser(user: User)

    /**
     * Deletes a user from the database by their ID.
     *
     * @param userId The ID of the user to delete
     * @return The number of users deleted (0 or 1)
     */
    @Query("DELETE FROM User WHERE id = :userId")
    suspend fun deleteUserById(userId: String): Int

    /**
     * Checks if a user exists in the database by their ID.
     *
     * @param userId The ID of the user to check
     * @return true if the user exists, false otherwise
     */
    @Query("SELECT EXISTS(SELECT 1 FROM User WHERE id = :userId)")
    suspend fun userExists(userId: String): Boolean

    /**
     * Checks if an email address is already registered in the database.
     *
     * @param email The email address to check
     * @return true if the email is already registered, false otherwise
     */
    @Query("SELECT EXISTS(SELECT 1 FROM User WHERE email = :email)")
    suspend fun isEmailRegistered(email: String): Boolean

    /**
     * Checks if a phone number is already registered in the database.
     *
     * @param phoneNumber The phone number to check
     * @return true if the phone number is already registered, false otherwise
     */
    @Query("SELECT EXISTS(SELECT 1 FROM User WHERE phoneNumber = :phoneNumber)")
    suspend fun isPhoneNumberRegistered(phoneNumber: String): Boolean
}