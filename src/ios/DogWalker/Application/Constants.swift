//
// Constants.swift
// DogWalker
//
// Human Tasks:
// 1. Verify the MAP_API_KEY is properly configured in Google Cloud Console for iOS platform
// 2. Ensure BASE_API_URL is correctly set for the deployment environment
// 3. Update API_TIMEOUT value based on network performance requirements
// 4. Verify DEFAULT_DATE_FORMAT matches backend API date format specification

import Foundation

/// Constants used throughout the DogWalker iOS application
/// Requirement: Centralized Configuration Management (Technical Specification/8.3 API Design/8.3.2 API Specifications)
/// Ensures consistent configuration across the application
public enum Constants {
    
    // MARK: - API Configuration
    
    /// Base URL for the DogWalker API
    public static let BASE_API_URL: String = "https://api.dogwalker.com"
    
    /// Timeout interval for API requests in seconds
    public static let API_TIMEOUT: Int = 30
    
    // MARK: - Date Formatting
    
    /// Default date format string for API requests and responses
    /// Format: 2023-12-31T23:59:59Z
    public static let DEFAULT_DATE_FORMAT: String = "yyyy-MM-dd'T'HH:mm:ssZ"
    
    // MARK: - Third-Party Integration Keys
    
    /// Google Maps API key for iOS platform
    /// Note: Configured through Google Cloud Console
    public static let MAP_API_KEY: String = "AIzaSyD-ExampleKeyForMapsAPI"
    
    // MARK: - Private Initializer
    
    /// Private initializer to prevent instantiation
    private init() {}
}

// MARK: - Internal Extensions

internal extension Constants {
    /// Returns a DateFormatter configured with the default date format
    static var defaultDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = DEFAULT_DATE_FORMAT
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }
    
    /// Returns a URLSessionConfiguration with the default timeout
    static var defaultURLSessionConfiguration: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(API_TIMEOUT)
        configuration.timeoutIntervalForResource = TimeInterval(API_TIMEOUT)
        return configuration
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension Constants {
    /// Validates that all required constants are properly configured
    static func validateConfiguration() {
        assert(!BASE_API_URL.isEmpty, "BASE_API_URL must not be empty")
        assert(API_TIMEOUT > 0, "API_TIMEOUT must be greater than 0")
        assert(!DEFAULT_DATE_FORMAT.isEmpty, "DEFAULT_DATE_FORMAT must not be empty")
        assert(!MAP_API_KEY.isEmpty, "MAP_API_KEY must not be empty")
        assert(MAP_API_KEY != "AIzaSyD-ExampleKeyForMapsAPI", "MAP_API_KEY must be updated with a valid key")
    }
}
#endif