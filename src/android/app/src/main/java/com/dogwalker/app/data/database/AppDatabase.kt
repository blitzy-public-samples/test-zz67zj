/**
 * Human Tasks:
 * 1. Verify Room database configuration in app's build.gradle (version 2.5.0)
 * 2. Ensure proper database migration strategy is implemented when schema changes
 * 3. Configure database backup and recovery mechanisms
 * 4. Set up database encryption if handling sensitive user data
 * 5. Configure database testing with sample data
 */

package com.dogwalker.app.data.database

// Room Database - version 2.5.0
import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters

// Entity imports
import com.dogwalker.app.data.database.entity.BookingEntity
import com.dogwalker.app.data.database.entity.DogEntity
import com.dogwalker.app.data.database.entity.UserEntity

// DAO imports
import com.dogwalker.app.data.database.dao.BookingDao
import com.dogwalker.app.data.database.dao.DogDao
import com.dogwalker.app.data.database.dao.UserDao

/**
 * Main database class for the Dog Walker application.
 * 
 * Requirements addressed:
 * - User Management (1.3 Scope/Core Features/User Management)
 *   Provides database infrastructure for managing user profiles through UserDao
 * 
 * - Dog Profile Management (1.3 Scope/Core Features/User Management)
 *   Supports persistence and retrieval of dog profiles through DogDao
 * 
 * - Booking System (1.3 Scope/Core Features/Booking System)
 *   Enables booking management through BookingDao
 * 
 * - Service Execution (1.3 Scope/Core Features/Service Execution)
 *   Supports walk data persistence including tracking and status management
 */
@Database(
    entities = [
        BookingEntity::class,
        DogEntity::class,
        UserEntity::class
    ],
    version = 1,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    /**
     * Provides access to booking-related database operations
     */
    abstract fun bookingDao(): BookingDao

    /**
     * Provides access to dog-related database operations
     */
    abstract fun dogDao(): DogDao

    /**
     * Provides access to user-related database operations
     */
    abstract fun userDao(): UserDao

    companion object {
        /**
         * Database file name
         */
        const val DATABASE_NAME = "dogwalker.db"
    }
}