package com.dogwalker.app.di

// Dagger Hilt - version 2.44
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent

// Javax Inject - version 1.0
import javax.inject.Singleton

// Internal imports
import com.dogwalker.app.data.api.ApiService
import com.dogwalker.app.data.database.AppDatabase
import com.dogwalker.app.data.repository.AuthRepository
import com.dogwalker.app.data.repository.BookingRepository
import com.dogwalker.app.data.repository.UserRepository

/**
 * Human Tasks:
 * 1. Verify Dagger Hilt is properly configured in the application module
 * 2. Ensure all required dependencies are included in the project's build.gradle
 * 3. Review dependency scoping to match application requirements
 * 4. Configure ProGuard rules for dependency injection if using code minification
 */

/**
 * AppModule provides application-level dependencies using Dagger Hilt.
 *
 * Requirement addressed: Dependency Injection (7.2 Component Details/Core Components)
 * Implements dependency injection for core application components such as repositories
 * and services, ensuring a modular and testable architecture.
 */
@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    /**
     * Provides a singleton instance of AuthRepository.
     *
     * @param apiService The API service instance for network operations
     * @param appDatabase The database instance for local storage
     * @return Singleton instance of AuthRepository
     *
     * Requirement addressed: Dependency Injection (7.2 Component Details/Core Components)
     * Provides the authentication repository with its required dependencies.
     */
    @Provides
    @Singleton
    fun provideAuthRepository(
        apiService: ApiService,
        appDatabase: AppDatabase
    ): AuthRepository {
        return AuthRepository(apiService, appDatabase)
    }

    /**
     * Provides a singleton instance of BookingRepository.
     *
     * @param appDatabase The database instance containing the BookingDao
     * @return Singleton instance of BookingRepository
     *
     * Requirement addressed: Dependency Injection (7.2 Component Details/Core Components)
     * Provides the booking repository with its required dependencies.
     */
    @Provides
    @Singleton
    fun provideBookingRepository(
        appDatabase: AppDatabase
    ): BookingRepository {
        return BookingRepository(appDatabase.bookingDao())
    }

    /**
     * Provides a singleton instance of UserRepository.
     *
     * @param appDatabase The database instance containing the UserDao
     * @return Singleton instance of UserRepository
     *
     * Requirement addressed: Dependency Injection (7.2 Component Details/Core Components)
     * Provides the user repository with its required dependencies.
     */
    @Provides
    @Singleton
    fun provideUserRepository(
        appDatabase: AppDatabase
    ): UserRepository {
        return UserRepository(appDatabase)
    }
}