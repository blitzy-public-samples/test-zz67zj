package com.dogwalker.app.data.api

// Retrofit v2.9.0
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.Body
import retrofit2.http.Path

/**
 * Human Tasks:
 * 1. Verify API endpoint paths match the backend service routes
 * 2. Ensure response models (User, Booking) match the backend API response structure
 * 3. Confirm authentication headers are properly configured in the API client
 * 4. Review error handling and response mapping for each endpoint
 */

/**
 * ApiService interface defines the API endpoints for interacting with the backend services
 * in the Dog Walker application.
 *
 * Requirement addressed: Backend Services (1.2 System Overview/Backend Services)
 * Implements the client-side interface for the cloud-based microservices architecture,
 * providing endpoints for user details and booking management.
 */
interface ApiService {

    /**
     * Fetches user details from the backend API.
     *
     * @param userId The unique identifier of the user
     * @return User object containing the user's details
     *
     * Requirement addressed: Backend Services (1.2 System Overview/Backend Services)
     * Implements user data retrieval from the backend microservice.
     */
    @GET("users/{userId}")
    suspend fun getUserDetails(@Path("userId") userId: String): User

    /**
     * Creates a new booking by sending booking details to the backend API.
     *
     * @param booking The booking details to be created
     * @return Booking object containing the created booking information
     *
     * Requirement addressed: Backend Services (1.2 System Overview/Backend Services)
     * Implements booking creation functionality through the backend microservice.
     */
    @POST("bookings")
    suspend fun createBooking(@Body booking: Booking): Booking
}