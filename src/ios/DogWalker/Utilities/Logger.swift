//
// Logger.swift
// DogWalker
//

// Human Tasks:
// 1. Review log levels and adjust based on environment (development/staging/production)
// 2. Configure log output destination based on environment (console/file/remote service)
// 3. Verify log format meets the team's debugging and monitoring requirements

import Foundation

/// Provides centralized logging functionality for the DogWalker application
/// Requirement: Centralized Logging (Technical Specification/7.4 Cross-Cutting Concerns/7.4.1 Monitoring and Observability)
/// Ensures consistent logging format and behavior across the application
public enum Logger {
    
    // MARK: - Log Levels
    
    /// Defines available log levels for message categorization
    public enum Level: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        
        /// ANSI color codes for console output
        fileprivate var color: String {
            switch self {
            case .debug: return "\u{001B}[36m" // Cyan
            case .info: return "\u{001B}[32m"  // Green
            case .warning: return "\u{001B}[33m" // Yellow
            case .error: return "\u{001B}[31m"  // Red
            }
        }
    }
    
    // MARK: - Private Properties
    
    /// Reset code for ANSI colors
    private static let colorReset = "\u{001B}[0m"
    
    /// Queue for thread-safe logging
    private static let logQueue = DispatchQueue(label: "com.dogwalker.logger", qos: .utility)
    
    // MARK: - Public Methods
    
    /// Logs a message with the specified level
    /// - Parameters:
    ///   - message: The message to log
    ///   - level: The severity level of the log message (default: .info)
    ///   - file: The file where the log was called from
    ///   - function: The function where the log was called from
    ///   - line: The line number where the log was called from
    public static func log(
        _ message: String,
        level: Level = .info,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        logQueue.async {
            let timestamp = DateFormatter.stringFromDate(Date())
            let fileName = (file as NSString).lastPathComponent
            
            // Construct the log entry with source information and consistent formatting
            let logEntry = "\(level.color)[\(timestamp)] [\(level.rawValue)] \(fileName):\(line) - \(function): \(message)\(colorReset)"
            
            // Print to console
            print(logEntry)
            
            #if DEBUG
            // In debug builds, flush the output buffer immediately
            fflush(stdout)
            #endif
        }
    }
    
    // MARK: - Convenience Methods
    
    /// Logs a debug message
    /// - Parameter message: The debug message to log
    public static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    /// Logs an info message
    /// - Parameter message: The info message to log
    public static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    /// Logs a warning message
    /// - Parameter message: The warning message to log
    public static func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    /// Logs an error message
    /// - Parameter message: The error message to log
    public static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
    
    // MARK: - Private Initializer
    
    /// Private initializer to prevent instantiation
    private init() {}
}

// MARK: - Debug Helpers

#if DEBUG
extension Logger {
    /// Tests all log levels to verify proper formatting and output
    static func testLogLevels() {
        debug("This is a debug message")
        info("This is an info message")
        warning("This is a warning message")
        error("This is an error message")
    }
}
#endif