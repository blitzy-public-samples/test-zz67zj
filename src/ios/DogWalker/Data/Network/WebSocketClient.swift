// Foundation framework - Latest
import Foundation

/// WebSocketClient: Manages WebSocket connections for real-time communication in the DogWalker iOS application
/// Requirement addressed: Real-Time Features (Technical Specification/1.2 System Overview/High-Level Description)
/// Implements WebSocket-based real-time communication for live tracking and messaging
class WebSocketClient {
    
    // MARK: - Human Tasks
    /*
    1. Configure WebSocket endpoint URLs in environment configuration
    2. Set up SSL certificate pinning for WebSocket connections
    3. Test WebSocket reconnection behavior under different network conditions
    4. Configure WebSocket timeout values based on application requirements
    */
    
    // MARK: - Properties
    
    /// Flag indicating if WebSocket is currently connected
    private(set) var isConnected: Bool = false
    
    /// Current WebSocket task instance
    private var webSocketTask: URLSessionWebSocketTask?
    
    /// URLSession for WebSocket communication
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(Constants.API_TIMEOUT)
        configuration.timeoutIntervalForResource = TimeInterval(Constants.API_TIMEOUT * 2)
        return URLSession(configuration: configuration)
    }()
    
    /// Queue for handling WebSocket operations
    private let wsQueue = DispatchQueue(label: "com.dogwalker.websocket", qos: .userInitiated)
    
    /// Retry attempt counter for reconnection
    private var retryCount: Int = 0
    
    /// Maximum number of retry attempts
    private let maxRetryAttempts = 5
    
    /// Base delay for exponential backoff (in seconds)
    private let baseRetryDelay: TimeInterval = 1.0
    
    // MARK: - Initialization
    
    init() {
        Logger.info("WebSocketClient initialized")
        setupReachabilityMonitoring()
    }
    
    // MARK: - Public Methods
    
    /// Establishes a WebSocket connection to the specified endpoint
    /// - Parameter endpoint: The endpoint path for WebSocket connection
    func connect(endpoint: String) {
        wsQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Check network connectivity
            guard NetworkMonitor.shared.checkConnectivity() else {
                Logger.error("Cannot establish WebSocket connection - No network connectivity")
                return
            }
            
            // Construct WebSocket URL using APIEndpoints
            let wsEndpoint = APIEndpoints().connectWebSocket(endpoint: endpoint)
            guard let url = URL(string: wsEndpoint) else {
                Logger.error("Invalid WebSocket URL: \(wsEndpoint)")
                return
            }
            
            // Create and configure WebSocket task
            self.webSocketTask = self.session.webSocketTask(with: url)
            self.webSocketTask?.maximumMessageSize = 1024 * 1024 // 1MB message size limit
            
            // Start receiving messages
            self.receiveMessage()
            
            // Resume the task to establish connection
            self.webSocketTask?.resume()
            
            Logger.info("WebSocket connection initiated to: \(wsEndpoint)")
            self.isConnected = true
            self.retryCount = 0
            
            // Start ping timer to keep connection alive
            self.startPingTimer()
        }
    }
    
    /// Sends a message through the WebSocket connection
    /// - Parameter message: The message to send
    func sendMessage(_ message: String) {
        guard isConnected, let webSocketTask = webSocketTask else {
            Logger.error("Cannot send message - WebSocket not connected")
            return
        }
        
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask.send(message) { [weak self] error in
            if let error = error {
                Logger.error("Failed to send WebSocket message: \(error.localizedDescription)")
                self?.handleError(error)
            } else {
                Logger.info("WebSocket message sent successfully")
            }
        }
    }
    
    /// Receives messages from the WebSocket connection
    func receiveMessage() {
        guard let webSocketTask = webSocketTask else {
            Logger.error("Cannot receive messages - WebSocket task not initialized")
            return
        }
        
        webSocketTask.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    Logger.info("Received WebSocket message: \(text)")
                    // Continue listening for next message
                    self.receiveMessage()
                    
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        Logger.info("Received WebSocket data message: \(text)")
                    } else {
                        Logger.warning("Received WebSocket binary data")
                    }
                    // Continue listening for next message
                    self.receiveMessage()
                    
                @unknown default:
                    Logger.warning("Received unknown WebSocket message type")
                    self.receiveMessage()
                }
                
            case .failure(let error):
                Logger.error("WebSocket receive error: \(error.localizedDescription)")
                self.handleError(error)
            }
        }
    }
    
    /// Closes the WebSocket connection gracefully
    func disconnect() {
        wsQueue.async { [weak self] in
            guard let self = self else { return }
            
            guard let webSocketTask = self.webSocketTask else {
                Logger.warning("WebSocket already disconnected")
                return
            }
            
            // Send close frame
            webSocketTask.cancel(with: .goingAway, reason: "Client disconnecting".data(using: .utf8))
            
            // Clean up resources
            self.webSocketTask = nil
            self.isConnected = false
            Logger.info("WebSocket disconnected")
        }
    }
    
    // MARK: - Private Methods
    
    /// Sets up network reachability monitoring
    private func setupReachabilityMonitoring() {
        ReachabilityUtility.initializeReachability()
        
        // Observe network status changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNetworkStatusChange(_:)),
            name: NetworkMonitor.networkStatusChangedNotification,
            object: nil
        )
    }
    
    /// Handles network status changes
    @objc private func handleNetworkStatusChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let isReachable = userInfo["isConnected"] as? Bool else {
            return
        }
        
        if !isReachable {
            Logger.warning("Network connectivity lost")
            disconnect()
        } else if !isConnected {
            Logger.info("Network connectivity restored - Attempting reconnection")
            attemptReconnection()
        }
    }
    
    /// Attempts to reconnect to WebSocket with exponential backoff
    private func attemptReconnection() {
        guard retryCount < maxRetryAttempts else {
            Logger.error("Maximum WebSocket reconnection attempts reached")
            return
        }
        
        let delay = baseRetryDelay * pow(2.0, Double(retryCount))
        retryCount += 1
        
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }
            
            Logger.info("Attempting WebSocket reconnection (Attempt \(self.retryCount)/\(self.maxRetryAttempts))")
            self.connect(endpoint: "/ws") // Use default endpoint
        }
    }
    
    /// Starts a timer to send periodic ping frames
    private func startPingTimer() {
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] timer in
            guard let self = self,
                  self.isConnected,
                  let webSocketTask = self.webSocketTask else {
                timer.invalidate()
                return
            }
            
            webSocketTask.sendPing { error in
                if let error = error {
                    Logger.error("WebSocket ping failed: \(error.localizedDescription)")
                    self.handleError(error)
                }
            }
        }
    }
    
    /// Handles WebSocket errors
    private func handleError(_ error: Error) {
        Logger.error("WebSocket error: \(error.localizedDescription)")
        
        if isConnected {
            disconnect()
            attemptReconnection()
        }
    }
    
    // MARK: - Deinitializer
    
    deinit {
        disconnect()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension WebSocketClient {
    /// Simulates a WebSocket connection failure
    func simulateConnectionFailure() {
        Logger.debug("Simulating WebSocket connection failure")
        handleError(NSError(domain: "WebSocketClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Simulated connection failure"]))
    }
    
    /// Tests WebSocket connection with logging
    func testConnection(endpoint: String) {
        Logger.debug("Testing WebSocket connection to endpoint: \(endpoint)")
        connect(endpoint: endpoint)
    }
}
#endif