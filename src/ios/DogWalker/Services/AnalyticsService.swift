// Foundation framework - Latest
import Foundation

/// AnalyticsService: Provides analytics tracking capabilities for the DogWalker iOS application
/// Requirement: User Behavior Tracking (Technical Specification/9.4 THIRD-PARTY SERVICES/Analytics)
/// Enables event logging and user behavior tracking throughout the application

// Human Tasks:
// 1. Review analytics event naming conventions with the team
// 2. Configure analytics endpoint in production environment
// 3. Set up monitoring for analytics data transmission
// 4. Verify analytics payload format matches backend requirements

final class AnalyticsService {
    
    // MARK: - Properties
    
    /// Shared instance for singleton access
    static let shared = AnalyticsService()
    
    /// API client for network requests
    private let apiClient: APIClient
    
    /// Base URL for analytics endpoints
    private var baseURL: String
    
    /// Flag to track initialization status
    private var isInitialized = false
    
    // MARK: - Constants
    
    private enum Constants {
        static let analyticsEndpoint = "/analytics/events"
        static let maxRetryAttempts = 3
        static let retryDelay: TimeInterval = 2.0
    }
    
    // MARK: - Initialization
    
    private init() {
        self.apiClient = APIClient()
        self.baseURL = AppConfiguration.BASE_API_URL
    }
    
    // MARK: - Public Methods
    
    /// Initializes the analytics service
    /// - Throws: APIError if initialization fails
    func initialize() {
        guard !isInitialized else {
            Logger.warning("Analytics service already initialized")
            return
        }
        
        guard !baseURL.isEmpty else {
            Logger.error("Base URL not configured for analytics service")
            return
        }
        
        Logger.info("Initializing analytics service with base URL: \(baseURL)")
        isInitialized = true
    }
    
    /// Tracks an analytics event with optional parameters
    /// - Parameters:
    ///   - eventName: Name of the event to track
    ///   - parameters: Optional dictionary of event parameters
    func trackEvent(eventName: String, parameters: [String: Any]? = nil) {
        guard isInitialized else {
            Logger.error("Analytics service not initialized. Call initialize() first")
            return
        }
        
        guard !eventName.isEmpty else {
            Logger.error("Event name cannot be empty")
            return
        }
        
        // Log the event for debugging
        if let params = parameters {
            Logger.info("Tracking event: \(eventName) with parameters: \(params)")
        } else {
            Logger.info("Tracking event: \(eventName)")
        }
        
        // Construct analytics payload
        var payload: [String: Any] = [
            "event_name": eventName,
            "timestamp": DateFormatter.stringFromDate(Date()),
            "platform": "iOS",
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        ]
        
        // Add custom parameters if provided
        if let params = parameters {
            payload["parameters"] = params
        }
        
        // Send analytics data to backend
        sendAnalyticsData(payload)
    }
    
    // MARK: - Private Methods
    
    /// Sends analytics data to the backend with retry logic
    /// - Parameter payload: The analytics data payload
    private func sendAnalyticsData(_ payload: [String: Any], retryCount: Int = 0) {
        apiClient.performRequest(
            endpoint: Constants.analyticsEndpoint,
            parameters: payload
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                Logger.debug("Analytics event sent successfully")
                
            case .failure(let error):
                Logger.error("Failed to send analytics event: \(error.localizedDescription)")
                
                // Implement retry logic for failed requests
                if retryCount < Constants.maxRetryAttempts {
                    Logger.info("Retrying analytics event (Attempt \(retryCount + 1)/\(Constants.maxRetryAttempts))")
                    
                    DispatchQueue.global().asyncAfter(deadline: .now() + Constants.retryDelay) {
                        self.sendAnalyticsData(payload, retryCount: retryCount + 1)
                    }
                } else {
                    Logger.error("Max retry attempts reached for analytics event")
                }
            }
        }
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension AnalyticsService {
    /// Tests the analytics service with sample events
    func testAnalytics() {
        trackEvent(eventName: "test_event")
        trackEvent(eventName: "test_event_with_params", parameters: [
            "test_param": "test_value",
            "timestamp": Date().timeIntervalSince1970
        ])
    }
}
#endif