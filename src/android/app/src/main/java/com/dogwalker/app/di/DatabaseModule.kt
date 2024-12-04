/**
 * Human Tasks:
 * 1. Verify Room database version (2.5.0) is correctly specified in app's build.gradle
 * 2. Ensure Dagger Hilt version (2.44) is properly configured in project dependencies
 * 3. Configure database backup and recovery mechanisms
 * 4. Set up database encryption if handling sensitive user data
 * 5. Configure database testing with sample data
 */

package com.dogwalker.app.di

// Room Database - version 2.5.0
import androidx.room.Room

// Dagger Hilt - version 2.44
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent

// Javax Inject - version 1.0
import javax.inject.Singleton

// Android Components
import android.content.Context

// Internal Database Components
import com.dogwalker.app.data.database.AppDatabase
import com.dogwalker.app.data.database.dao.BookingDao
import com.dogwalker.app.data.database.dao.DogDao
import com.dogwalker.app.data.database.dao.UserDao
import com.dogwalker.app.data.database.dao.WalkDao

/**
 * Dagger Hilt module that provides database-related dependencies.
 * 
 * Requirements addressed:
 * - Dependency Injection (7.2 Component Details/Core Components)
 *   Provides singleton instances of the Room database and its DAOs
 *   ensuring consistent database access throughout the application.
 */
@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {

    /**
     * Provides the singleton instance of the Room database.
     *
     * @param context The application context used to create the database
     * @return A singleton instance of AppDatabase
     */
    @Provides
    @Singleton
    fun provideDatabase(context: Context): AppDatabase {
        return Room.databaseBuilder(
            context.applicationContext,
            AppDatabase::class.java,
            AppDatabase.DATABASE_NAME
        ).build()
    }

    /**
     * Provides the BookingDao instance for booking-related database operations.
     *
     * @param database The AppDatabase instance
     * @return The BookingDao instance
     */
    @Provides
    @Singleton
    fun provideBookingDao(database: AppDatabase): BookingDao {
        return database.bookingDao()
    }

    /**
     * Provides the DogDao instance for dog-related database operations.
     *
     * @param database The AppDatabase instance
     * @return The DogDao instance
     */
    @Provides
    @Singleton
    fun provideDogDao(database: AppDatabase): DogDao {
        return database.dogDao()
    }

    /**
     * Provides the UserDao instance for user-related database operations.
     *
     * @param database The AppDatabase instance
     * @return The UserDao instance
     */
    @Provides
    @Singleton
    fun provideUserDao(database: AppDatabase): UserDao {
        return database.userDao()
    }

    /**
     * Provides the WalkDao instance for walk-related database operations.
     *
     * @param database The AppDatabase instance
     * @return The WalkDao instance
     */
    @Provides
    @Singleton
    fun provideWalkDao(database: AppDatabase): WalkDao {
        return database.walkDao()
    }
}