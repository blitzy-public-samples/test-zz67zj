package com.dogwalker.app.util

/**
 * Human Tasks:
 * 1. Verify the BASE_API_URL matches the production API endpoint
 * 2. Ensure LOCATION_PERMISSION_REQUEST_CODE doesn't conflict with other permission request codes
 * 3. Confirm TIMEOUT_DURATION meets the application's performance requirements
 */

/**
 * Constants used throughout the DogWalker Android application.
 * 
 * Requirement addressed: Technical Specification/System Design/8.3 API Design - Global Constants
 * Provides reusable constant values for configuration, permissions, and other application-wide settings.
 */
object Constants {
    /**
     * Default timeout duration for network requests in milliseconds
     */
    const val TIMEOUT_DURATION: Long = 30000L

    /**
     * Request code for location permission requests
     * Used in permission handling for Android's runtime permissions
     */
    const val LOCATION_PERMISSION_REQUEST_CODE: Int = 1001

    /**
     * Base URL for the DogWalker API
     * All API endpoints will be appended to this base URL
     */
    const val BASE_API_URL: String = "https://api.dogwalker.com"
}