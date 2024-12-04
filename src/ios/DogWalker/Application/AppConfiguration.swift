//
// AppConfiguration.swift
// DogWalker
//
// Human Tasks:
// 1. Verify logging configuration meets production requirements
// 2. Review error handling strategy for configuration initialization
// 3. Ensure configuration values are properly secured in production builds

import Foundation
import os.log

/// AppConfiguration manages global application settings and initialization
/// Requirement: Centralized Configuration Management (Technical Specification/8.3 API Design/8.3.2 API Specifications)
public final class AppConfiguration {
    
    // MARK: - Singleton Instance
    
    /// Shared instance of AppConfiguration
    public static let shared = AppConfiguration()
    
    // MARK: - Private Properties
    
    private let logger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.dogwalker", category: "Configuration")
    
    private var isInitialized: Bool = false
    
    private var configurationValues: [String: Any] = [:]
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Initializes the global configuration settings for the application
    /// This method should be called during app launch before accessing any configuration values
    public func initialize() {
        guard !isInitialized else {
            os_log("Configuration already initialized", log: logger, type: .info)
            return
        }
        
        do {
            // Validate and store configuration values
            try validateAndStoreConfigurations()
            
            isInitialized = true
            
            #if DEBUG
            // Perform additional validation in debug builds
            Constants.validateConfiguration()
            logConfigurationValues()
            #endif
            
            os_log("Configuration initialized successfully", log: logger, type: .info)
            
        } catch {
            os_log("Configuration initialization failed: %{public}@", log: logger, type: .error, error.localizedDescription)
            fatalError("Failed to initialize application configuration: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Methods
    
    private func validateAndStoreConfigurations() throws {
        // Validate BASE_API_URL
        guard !Constants.BASE_API_URL.isEmpty else {
            throw ConfigurationError.invalidValue("BASE_API_URL cannot be empty")
        }
        configurationValues["baseApiUrl"] = Constants.BASE_API_URL
        
        // Validate API_TIMEOUT
        guard Constants.API_TIMEOUT > 0 else {
            throw ConfigurationError.invalidValue("API_TIMEOUT must be greater than 0")
        }
        configurationValues["apiTimeout"] = Constants.API_TIMEOUT
        
        // Validate DEFAULT_DATE_FORMAT
        guard !Constants.DEFAULT_DATE_FORMAT.isEmpty else {
            throw ConfigurationError.invalidValue("DEFAULT_DATE_FORMAT cannot be empty")
        }
        configurationValues["defaultDateFormat"] = Constants.DEFAULT_DATE_FORMAT
        
        // Validate MAP_API_KEY
        guard !Constants.MAP_API_KEY.isEmpty,
              Constants.MAP_API_KEY != "AIzaSyD-ExampleKeyForMapsAPI" else {
            throw ConfigurationError.invalidValue("Invalid MAP_API_KEY configuration")
        }
        configurationValues["mapApiKey"] = Constants.MAP_API_KEY
    }
    
    #if DEBUG
    private func logConfigurationValues() {
        os_log("Configuration Values:", log: logger, type: .debug)
        os_log("BASE_API_URL: %{public}@", log: logger, type: .debug, Constants.BASE_API_URL)
        os_log("API_TIMEOUT: %{public}d", log: logger, type: .debug, Constants.API_TIMEOUT)
        os_log("DEFAULT_DATE_FORMAT: %{public}@", log: logger, type: .debug, Constants.DEFAULT_DATE_FORMAT)
        os_log("MAP_API_KEY: [REDACTED]", log: logger, type: .debug)
    }
    #endif
}

// MARK: - Configuration Error

private enum ConfigurationError: LocalizedError {
    case invalidValue(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidValue(let message):
            return "Invalid configuration value: \(message)"
        }
    }
}

// MARK: - Configuration Value Access

extension AppConfiguration {
    /// Returns a configuration value for the given key
    /// - Parameter key: The configuration key
    /// - Returns: The configuration value if it exists
    internal func value<T>(for key: String) -> T? {
        guard isInitialized else {
            os_log("Attempting to access configuration before initialization", log: logger, type: .error)
            return nil
        }
        return configurationValues[key] as? T
    }
}