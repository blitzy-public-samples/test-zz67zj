//
// AppContainer.swift
// DogWalker
//

// Human Tasks:
// 1. Verify all dependencies are properly initialized in the correct order
// 2. Ensure memory management for singleton instances is appropriate
// 3. Review error handling strategy for dependency initialization failures
// 4. Test dependency injection container under different app lifecycle scenarios

import Foundation

// Internal imports with relative paths
import "Constants"
import "AppConfiguration"
import "Logger"
import "Reachability"

/// AppContainer: Manages dependency injection and application-wide services
/// Requirement: Dependency Injection (Technical Specification/7.3 Technical Decisions/7.3.1 Architecture Patterns)
/// Ensures that all components have access to their dependencies in a centralized and manageable way
public final class AppContainer {
    
    // MARK: - Singleton Instance
    
    /// Shared instance of AppContainer
    public static let shared = AppContainer()
    
    // MARK: - Dependencies
    
    /// Local router instance for navigation management
    private let localRouter: LocalAppRouter
    
    /// Flag to track initialization status
    private var isInitialized: Bool = false
    
    // MARK: - Initialization
    
    private init() {
        self.localRouter = LocalAppRouter()
        Logger.info("AppContainer initialized")
    }
    
    // MARK: - Public Methods
    
    /// Initializes all dependencies required for the application
    public func initializeDependencies() {
        guard !isInitialized else {
            Logger.warning("Dependencies already initialized")
            return
        }
        
        Logger.info("Starting dependency initialization")
        
        do {
            // Initialize app configuration
            AppConfiguration.shared.initialize()
            Logger.info("App configuration initialized with base URL: \(Constants.BASE_API_URL)")
            
            // Initialize local router
            localRouter.initializeRoutes()
            Logger.info("Local router initialized")
            
            // Initialize reachability monitoring
            ReachabilityUtility.shared.startReachabilityMonitoring()
            Logger.info("Reachability monitoring initialized with timeout: \(Constants.API_TIMEOUT)s")
            
            // Set default date format for the application
            DateFormatter.defaultDateFormatter.dateFormat = Constants.DEFAULT_DATE_FORMAT
            Logger.info("Default date format configured: \(Constants.DEFAULT_DATE_FORMAT)")
            
            // Log successful initialization
            Logger.info("All dependencies initialized successfully")
            
            isInitialized = true
            
        } catch {
            Logger.error("Failed to initialize dependencies: \(error.localizedDescription)")
            fatalError("Dependency initialization failed")
        }
    }
}

// MARK: - LocalAppRouter Implementation

private final class LocalAppRouter {
    
    // MARK: - Properties
    
    /// Dictionary to store application routes
    private var routes: [String: Any] = [:]
    
    // MARK: - Initialization
    
    init() {
        Logger.info("LocalAppRouter initialized")
    }
    
    // MARK: - Public Methods
    
    /// Initializes the application routes
    func initializeRoutes() {
        // Define main navigation routes
        routes = [
            "home": "/home",
            "profile": "/profile",
            "walks": "/walks",
            "bookings": "/bookings",
            "payments": "/payments",
            "settings": "/settings"
        ]
        
        Logger.info("Routes initialized: \(routes.keys.joined(separator: ", "))")
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension AppContainer {
    /// Validates the initialization state of all dependencies
    func validateDependencies() {
        Logger.debug("Validating dependencies...")
        
        // Validate app configuration
        guard AppConfiguration.shared.value(for: "baseApiUrl") != nil else {
            Logger.error("App configuration not properly initialized")
            return
        }
        
        // Validate reachability
        guard ReachabilityUtility.shared.isNetworkReachable() != nil else {
            Logger.error("Reachability monitoring not properly initialized")
            return
        }
        
        // Validate local router
        guard !localRouter.routes.isEmpty else {
            Logger.error("Local router routes not properly initialized")
            return
        }
        
        Logger.debug("All dependencies validated successfully")
    }
}
#endif