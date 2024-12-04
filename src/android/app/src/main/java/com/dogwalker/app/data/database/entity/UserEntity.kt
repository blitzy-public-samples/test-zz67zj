package com.dogwalker.app.data.database.entity

// androidx.room:room-runtime:2.5.0
import androidx.room.Entity
import androidx.room.PrimaryKey
import com.dogwalker.app.domain.model.User

/**
 * Human Tasks:
 * 1. Ensure proper database indexing is configured for frequently queried fields
 * 2. Verify that the table name follows the project's database naming conventions
 * 3. Configure ProGuard rules to prevent obfuscation of this entity class if using R8/ProGuard
 * 4. Review and update database migration strategies when modifying the entity structure
 */

/**
 * Represents the user data structure in the local Room database.
 * 
 * Requirements addressed:
 * - User Management (1.3 Scope/Core Features/User Management)
 *   Provides a database entity for storing user profiles, including essential
 *   details such as name, email, phone number, and role.
 */
@Entity(tableName = "users")
data class UserEntity(
    @PrimaryKey
    val id: String,

    /**
     * Full name of the user
     */
    val name: String,

    /**
     * Email address of the user
     */
    val email: String,

    /**
     * Phone number of the user
     */
    val phone: String,

    /**
     * Role of the user in the system (e.g., "owner", "walker", "admin")
     */
    val role: String
) {
    /**
     * Converts this database entity to a domain model User object.
     * Note: Some fields are initialized with empty collections since they are not stored
     * in this table and should be fetched from their respective tables.
     */
    fun toDomainModel() = User(
        id = id,
        name = name,
        email = email,
        phoneNumber = phone,
        bookingIds = emptyList(), // Should be fetched from bookings table
        dogIds = emptyList(),     // Should be fetched from dogs table
        walks = emptyList()       // Should be fetched from walks table
    )

    companion object {
        /**
         * Creates a UserEntity from a domain model User object.
         * Note: This only maps the basic user properties that are stored in the users table.
         */
        fun fromDomainModel(user: User, role: String) = UserEntity(
            id = user.id,
            name = user.name,
            email = user.email,
            phone = user.phoneNumber,
            role = role
        )

        // Role constants
        const val ROLE_OWNER = "owner"
        const val ROLE_WALKER = "walker"
        const val ROLE_ADMIN = "admin"
    }
}