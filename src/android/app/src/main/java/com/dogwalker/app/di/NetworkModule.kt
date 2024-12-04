package com.dogwalker.app.di

// Retrofit v2.9.0
import retrofit2.Retrofit
// OkHttp v4.9.3
import okhttp3.OkHttpClient
// Retrofit Gson Converter v2.9.0
import retrofit2.converter.gson.GsonConverterFactory

import com.dogwalker.app.data.api.ApiService
import com.dogwalker.app.data.api.ApiClient
import com.dogwalker.app.util.Constants.BASE_API_URL
import java.util.concurrent.TimeUnit
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

/**
 * Human Tasks:
 * 1. Verify that Dagger Hilt is properly configured in the application module
 * 2. Ensure network security config is set up for production API endpoints
 * 3. Review and adjust timeout settings based on production requirements
 * 4. Configure ProGuard rules for Retrofit and OkHttp if using code minification
 * 5. Set up network monitoring and logging for production environment
 */

/**
 * NetworkModule provides network-related dependencies for the application using Dagger Hilt.
 *
 * Requirement addressed: Backend Services (1.2 System Overview/Backend Services)
 * Implements dependency injection for network components that interact with the cloud-based
 * microservices architecture, providing configured instances of Retrofit, OkHttpClient,
 * and ApiService for handling API requests.
 */
@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

    /**
     * Provides a configured OkHttpClient instance for network requests.
     *
     * @return OkHttpClient instance with custom timeout settings
     *
     * Requirement addressed: Backend Services (1.2 System Overview/Backend Services)
     * Configures the HTTP client with appropriate timeout settings for reliable
     * communication with the backend services.
     */
    @Provides
    @Singleton
    fun provideOkHttpClient(): OkHttpClient {
        return OkHttpClient.Builder()
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .build()
    }

    /**
     * Provides a configured Retrofit instance for making API calls.
     *
     * @param client The OkHttpClient instance to be used by Retrofit
     * @return Retrofit instance configured with the base URL and Gson converter
     *
     * Requirement addressed: Backend Services (1.2 System Overview/Backend Services)
     * Sets up the Retrofit client with proper configuration for interacting with
     * the backend microservices.
     */
    @Provides
    @Singleton
    fun provideRetrofit(client: OkHttpClient): Retrofit {
        return Retrofit.Builder()
            .baseUrl(BASE_API_URL)
            .client(client)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
    }

    /**
     * Provides an instance of the ApiService interface for making API calls.
     *
     * @param retrofit The Retrofit instance used to create the ApiService implementation
     * @return ApiService implementation for making API calls
     *
     * Requirement addressed: Backend Services (1.2 System Overview/Backend Services)
     * Creates an implementation of the ApiService interface for handling API requests
     * to the backend services.
     */
    @Provides
    @Singleton
    fun provideApiService(retrofit: Retrofit): ApiService {
        return retrofit.create(ApiService::class.java)
    }
}