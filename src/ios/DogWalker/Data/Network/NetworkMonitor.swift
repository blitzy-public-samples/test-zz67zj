// Network framework - Latest
import Network
// Foundation framework - Latest
import Foundation

// Human Tasks:
// 1. Verify network permissions are properly configured in Info.plist
// 2. Test network monitoring behavior in different connectivity scenarios
// 3. Configure network monitoring thresholds based on application requirements

/// NetworkMonitor: Monitors and reports network connectivity status for the DogWalker iOS application
/// Requirement: Network Connectivity Monitoring (Technical Specification/8.3 API Design/8.3.2 API Specifications)
/// Ensures that the application can detect and respond to changes in network connectivity
class NetworkMonitor {
    
    // MARK: - Properties
    
    /// Singleton instance for network monitoring
    static let shared = NetworkMonitor()
    
    /// Network path monitor instance
    private let monitor = NWPathMonitor()
    
    /// Queue for network monitoring operations
    private let monitorQueue = DispatchQueue(label: "com.dogwalker.networkmonitor")
    
    /// Current network connectivity status
    private(set) var isConnected: Bool = false {
        didSet {
            if oldValue != isConnected {
                Logger.info("Network connectivity changed: \(isConnected ? "Connected" : "Disconnected")")
            }
        }
    }
    
    /// APIClient instance for connectivity validation
    private let apiClient = APIClient()
    
    // MARK: - Initialization
    
    private init() {
        Logger.info("NetworkMonitor initialized")
        setupMonitor()
    }
    
    // MARK: - Public Methods
    
    /// Starts monitoring network connectivity
    func startMonitoring() {
        Logger.info("Starting network monitoring")
        monitor.start(queue: monitorQueue)
    }
    
    /// Stops monitoring network connectivity
    func stopMonitoring() {
        Logger.info("Stopping network monitoring")
        monitor.cancel()
    }
    
    /// Checks current network connectivity by performing a lightweight request
    /// - Returns: Boolean indicating if network is connected and functional
    func checkConnectivity() -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        var isReachable = false
        
        apiClient.performRequest(
            endpoint: "/health",
            parameters: nil
        ) { result in
            switch result {
            case .success(_):
                isReachable = true
            case .failure(let error):
                Logger.error("Connectivity check failed: \(error.localizedDescription)")
                isReachable = false
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + .seconds(Constants.API_TIMEOUT))
        return isReachable
    }
    
    // MARK: - Private Methods
    
    /// Sets up the network path monitor
    private func setupMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            // Update connectivity status based on path status
            self.isConnected = path.status == .satisfied
            
            // Log network interface type
            if self.isConnected {
                if path.usesInterfaceType(.wifi) {
                    Logger.info("Connected via WiFi")
                } else if path.usesInterfaceType(.cellular) {
                    Logger.info("Connected via Cellular")
                } else if path.usesInterfaceType(.wiredEthernet) {
                    Logger.info("Connected via Ethernet")
                } else {
                    Logger.info("Connected via other interface")
                }
            }
            
            // Log network constraints
            if path.isConstrained {
                Logger.warning("Network has constraints")
            }
            
            if path.isExpensive {
                Logger.warning("Network connection is expensive")
            }
        }
    }
}

// MARK: - Network Status Notifications

extension NetworkMonitor {
    /// Notification name for network status changes
    static let networkStatusChangedNotification = Notification.Name("NetworkStatusChanged")
    
    /// Posts a notification when network status changes
    private func notifyNetworkStatusChange() {
        NotificationCenter.default.post(
            name: NetworkMonitor.networkStatusChangedNotification,
            object: self,
            userInfo: ["isConnected": isConnected]
        )
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension NetworkMonitor {
    /// Simulates network status changes for testing
    func simulateNetworkStatusChange(isConnected: Bool) {
        self.isConnected = isConnected
        notifyNetworkStatusChange()
    }
}
#endif