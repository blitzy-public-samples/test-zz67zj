//
// DateFormatter+Extensions.swift
// DogWalker
//

import Foundation

/// Extension to DateFormatter providing consistent date formatting utilities
/// Requirement: Consistent Date Formatting (Technical Specification/8.3 API Design/8.3.2 API Specifications)
/// Ensures that all dates are formatted consistently across the application
extension DateFormatter {
    
    // MARK: - Private Properties
    
    /// Shared DateFormatter instance configured with the default format
    private static let sharedFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.DEFAULT_DATE_FORMAT
        formatter.locale = Locale(identifier: "en_US_POSIX") // Use POSIX locale for consistent parsing
        formatter.timeZone = TimeZone(secondsFromGMT: 0)    // Use UTC timezone for consistency
        return formatter
    }()
    
    // MARK: - Public Methods
    
    /// Converts a Date object to a formatted string using the default date format
    /// - Parameter date: The Date object to format
    /// - Returns: A string representation of the date in the default format
    static func stringFromDate(_ date: Date) -> String {
        return sharedFormatter.string(from: date)
    }
    
    /// Converts a formatted date string to a Date object using the default date format
    /// - Parameter dateString: The string to parse into a Date object
    /// - Returns: A Date object if the string is successfully parsed, nil otherwise
    static func dateFromString(_ dateString: String) -> Date? {
        return sharedFormatter.date(from: dateString)
    }
}

// MARK: - Thread Safety Note
/*
 The DateFormatter class is thread-safe in iOS 7 and later.
 The shared formatter instance is configured once during initialization
 and only used for read-only operations thereafter, making it safe
 for concurrent access across multiple threads.
*/