// Network framework - Latest
import Network
// Foundation framework - Latest
import Foundation

// Human Tasks:
// 1. Verify network permissions are properly configured in Info.plist
// 2. Test network monitoring behavior under different connectivity scenarios
// 3. Ensure proper error handling for network state changes
// 4. Review timeout values for network connectivity checks

/// Reachability: A utility class for monitoring and handling network reachability status
/// Requirement: Network Connectivity Monitoring (Technical Specification/8.3 API Design/8.3.2 API Specifications)
/// Ensures that the application can detect and respond to changes in network connectivity
class Reachability {
    
    // MARK: - Properties
    
    /// Shared instance for singleton access
    static let shared = Reachability()
    
    /// Current network reachability status
    private(set) var isReachable: Bool = false {
        didSet {
            if oldValue != isReachable {
                Logger.info("Network reachability changed: \(isReachable ? "Connected" : "Disconnected")")
            }
        }
    }
    
    /// Network monitor instance for connectivity tracking
    private let networkMonitor: NetworkMonitor
    
    // MARK: - Initialization
    
    private init() {
        self.networkMonitor = NetworkMonitor.shared
        Logger.info("Reachability utility initialized")
    }
    
    // MARK: - Public Methods
    
    /// Starts monitoring network reachability status
    func startReachabilityMonitoring() {
        Logger.info("Starting reachability monitoring")
        
        // Start the network monitor
        networkMonitor.startMonitoring()
        
        // Set up observation of network status
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNetworkStatusChange(_:)),
            name: NetworkMonitor.networkStatusChangedNotification,
            object: nil
        )
        
        // Update initial reachability status
        isReachable = networkMonitor.isConnected
    }
    
    /// Stops monitoring network reachability status
    func stopReachabilityMonitoring() {
        Logger.info("Stopping reachability monitoring")
        
        // Stop the network monitor
        networkMonitor.stopMonitoring()
        
        // Remove notification observer
        NotificationCenter.default.removeObserver(
            self,
            name: NetworkMonitor.networkStatusChangedNotification,
            object: nil
        )
        
        // Update reachability status
        isReachable = false
    }
    
    /// Checks if the network is currently reachable
    /// - Returns: Boolean indicating if network is reachable
    func isNetworkReachable() -> Bool {
        let currentStatus = networkMonitor.isConnected
        Logger.info("Network reachability status: \(currentStatus ? "Connected" : "Disconnected")")
        return currentStatus
    }
    
    // MARK: - Private Methods
    
    /// Handles network status change notifications
    /// - Parameter notification: The notification containing network status information
    @objc private func handleNetworkStatusChange(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let connected = userInfo["isConnected"] as? Bool {
            isReachable = connected
            
            // Log the network status change with timeout context
            Logger.info("Network status updated - Connected: \(connected) (Timeout: \(Constants.API_TIMEOUT)s)")
        }
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension Reachability {
    /// Simulates a network reachability status change
    /// - Parameter reachable: The simulated reachability status
    func simulateReachabilityChange(reachable: Bool) {
        Logger.debug("Simulating reachability change: \(reachable ? "Connected" : "Disconnected")")
        isReachable = reachable
    }
    
    /// Performs a connectivity test with logging
    func testConnectivity() {
        Logger.debug("Testing network connectivity...")
        let status = isNetworkReachable()
        Logger.debug("Connectivity test result: \(status ? "Success" : "Failure")")
    }
}
#endif