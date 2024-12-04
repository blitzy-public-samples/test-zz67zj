package com.dogwalker.app.util

import com.dogwalker.app.util.Constants.TIMEOUT_DURATION
import java.text.SimpleDateFormat // Java SDK
import java.util.Date // Java SDK
import java.util.Locale // Java SDK

/**
 * Human Tasks:
 * 1. Verify that the date format patterns used in the application match the UI/UX requirements
 * 2. Ensure the locale settings are appropriate for the target market regions
 * 3. Consider adding timezone handling if the application needs to support multiple timezones
 */

/**
 * Utility object providing date and time operations for the DogWalker application.
 * 
 * Requirement addressed: Technical Specification/System Design/8.3 API Design - Date and Time Management
 * Provides utility functions to support date and time operations for scheduling and tracking features.
 */
object DateUtils {

    /**
     * Formats a given Date object into a string based on the specified pattern.
     *
     * @param date The Date object to format
     * @param pattern The format pattern (e.g., "yyyy-MM-dd HH:mm:ss")
     * @return A formatted string representation of the date
     * @throws IllegalArgumentException if the pattern is invalid
     */
    @Throws(IllegalArgumentException::class)
    fun formatDate(date: Date, pattern: String): String {
        return try {
            val dateFormat = SimpleDateFormat(pattern, Locale.getDefault())
            dateFormat.format(date)
        } catch (e: IllegalArgumentException) {
            throw IllegalArgumentException("Invalid date pattern: $pattern", e)
        }
    }

    /**
     * Parses a date string into a Date object based on the specified pattern.
     *
     * @param dateString The string representation of the date
     * @param pattern The format pattern that matches the date string format
     * @return A Date object representing the parsed date
     * @throws IllegalArgumentException if the pattern is invalid or the date string doesn't match the pattern
     */
    @Throws(IllegalArgumentException::class)
    fun parseDate(dateString: String, pattern: String): Date {
        return try {
            val dateFormat = SimpleDateFormat(pattern, Locale.getDefault())
            dateFormat.isLenient = false // Strict parsing to ensure date validity
            dateFormat.parse(dateString) ?: throw IllegalArgumentException("Failed to parse date: $dateString")
        } catch (e: Exception) {
            throw IllegalArgumentException("Failed to parse date '$dateString' with pattern '$pattern'", e)
        }
    }

    /**
     * Calculates the duration in milliseconds between two Date objects.
     * 
     * Note: This function uses TIMEOUT_DURATION from Constants as a reference for validation
     * to ensure the calculated duration doesn't exceed reasonable limits.
     *
     * @param startDate The starting date
     * @param endDate The ending date
     * @return The duration in milliseconds
     * @throws IllegalArgumentException if the end date is before the start date or if the duration exceeds reasonable limits
     */
    @Throws(IllegalArgumentException::class)
    fun calculateDuration(startDate: Date, endDate: Date): Long {
        if (endDate.before(startDate)) {
            throw IllegalArgumentException("End date cannot be before start date")
        }

        val duration = endDate.time - startDate.time
        
        // Validate that the duration is within reasonable limits
        // Using TIMEOUT_DURATION as a reference for maximum reasonable duration
        if (duration > TIMEOUT_DURATION * 1000) { // Convert TIMEOUT_DURATION to a reasonable maximum
            throw IllegalArgumentException("Calculated duration exceeds reasonable limits")
        }

        return duration
    }
}