//
// APIEndpoints.swift
// DogWalker
//
// Human Tasks:
// 1. Configure the base URL in the environment configuration file
// 2. Set up SSL certificate pinning for production environment
// 3. Configure network security settings in Info.plist
// 4. Set up error reporting and monitoring service credentials

import Foundation // Latest

/// APIEndpoints class manages API endpoint constants and provides utility methods for constructing URLs.
/// Requirement addressed: 8.3.2/API Specifications - Provides a centralized definition of API endpoints and utilities for constructing URLs.
class APIEndpoints {
    
    // MARK: - Properties
    
    /// Base URL for the API endpoints
    private let baseURL: String
    
    /// Session configuration for network requests
    private let sessionConfiguration: URLSessionConfiguration
    
    /// URLSession instance for making network requests
    private lazy var session: URLSession = {
        return URLSession(configuration: sessionConfiguration)
    }()
    
    // MARK: - Constants
    
    private enum Endpoints {
        static let users = "/api/v1/users"
        static let walkers = "/api/v1/walkers"
        static let bookings = "/api/v1/bookings"
        static let walks = "/api/v1/walks"
        static let payments = "/api/v1/payments"
        static let tracking = "/api/v1/tracking"
        static let websocket = "/ws"
    }
    
    private enum HTTPHeaders {
        static let contentType = "Content-Type"
        static let authorization = "Authorization"
        static let accept = "Accept"
        static let apiVersion = "X-API-Version"
    }
    
    // MARK: - Initialization
    
    /// Initializes the APIEndpoints class with a default base URL
    init() {
        // Initialize with the base URL from configuration
        #if DEBUG
        self.baseURL = "https://api.dev.dogwalker.com"
        #else
        self.baseURL = "https://api.dogwalker.com"
        #endif
        
        // Configure session with default settings
        self.sessionConfiguration = URLSessionConfiguration.default
        self.sessionConfiguration.timeoutIntervalForRequest = 30
        self.sessionConfiguration.timeoutIntervalForResource = 300
        self.sessionConfiguration.waitsForConnectivity = true
        
        // Set default headers
        self.sessionConfiguration.httpAdditionalHeaders = [
            HTTPHeaders.contentType: "application/json",
            HTTPHeaders.accept: "application/json",
            HTTPHeaders.apiVersion: "1.0"
        ]
    }
    
    // MARK: - URL Construction
    
    /// Constructs a full URL for a given API endpoint
    /// - Parameter endpoint: The API endpoint path
    /// - Returns: The full URL string for the specified endpoint
    func urlForEndpoint(_ endpoint: String) -> String {
        // Ensure the endpoint starts with a forward slash
        let normalizedEndpoint = endpoint.hasPrefix("/") ? endpoint : "/\(endpoint)"
        
        // Combine base URL with endpoint
        let fullURL = baseURL + normalizedEndpoint
        
        // Validate the URL
        guard URL(string: fullURL) != nil else {
            assertionFailure("Invalid URL constructed: \(fullURL)")
            return baseURL
        }
        
        return fullURL
    }
    
    // MARK: - Network Requests
    
    /// Performs a network request to the specified endpoint with the given parameters
    /// - Parameters:
    ///   - endpoint: The API endpoint to request
    ///   - parameters: Dictionary of parameters to include in the request
    func performRequest(endpoint: String, parameters: [String: Any]) {
        // Construct the URL
        let urlString = urlForEndpoint(endpoint)
        guard let url = URL(string: urlString) else {
            assertionFailure("Invalid URL: \(urlString)")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            // Serialize parameters to JSON
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            
            // Perform the request
            let task = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    // Handle network error
                    print("Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response type")
                    return
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    // Handle success
                    if let data = data {
                        // Process response data
                        self.handleSuccessResponse(data)
                    }
                case 400...499:
                    // Handle client errors
                    self.handleClientError(httpResponse.statusCode, data)
                case 500...599:
                    // Handle server errors
                    self.handleServerError(httpResponse.statusCode, data)
                default:
                    print("Unexpected status code: \(httpResponse.statusCode)")
                }
            }
            
            task.resume()
        } catch {
            print("Failed to serialize parameters: \(error.localizedDescription)")
        }
    }
    
    // MARK: - WebSocket Connection
    
    /// Establishes a WebSocket connection to the specified endpoint
    /// - Parameter endpoint: The WebSocket endpoint to connect to
    func connectWebSocket(endpoint: String) {
        // Construct WebSocket URL
        let wsEndpoint = endpoint.hasPrefix("/") ? endpoint : "/\(endpoint)"
        #if DEBUG
        let wsURL = "wss://ws.dev.dogwalker.com\(wsEndpoint)"
        #else
        let wsURL = "wss://ws.dogwalker.com\(wsEndpoint)"
        #endif
        
        guard let url = URL(string: wsURL) else {
            assertionFailure("Invalid WebSocket URL: \(wsURL)")
            return
        }
        
        // Create WebSocket task
        let webSocketTask = session.webSocketTask(with: url)
        
        // Handle connection
        webSocketTask.resume()
        
        // Listen for messages
        self.receiveWebSocketMessage(webSocketTask)
        
        // Set up ping timer to keep connection alive
        self.startWebSocketPingTimer(webSocketTask)
    }
    
    // MARK: - Private Helper Methods
    
    private func handleSuccessResponse(_ data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                // Process JSON response
                print("Received response: \(json)")
            }
        } catch {
            print("Failed to parse response: \(error.localizedDescription)")
        }
    }
    
    private func handleClientError(_ statusCode: Int, _ data: Data?) {
        if let data = data,
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            print("Client error \(statusCode): \(json)")
        } else {
            print("Client error \(statusCode)")
        }
    }
    
    private func handleServerError(_ statusCode: Int, _ data: Data?) {
        if let data = data,
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            print("Server error \(statusCode): \(json)")
        } else {
            print("Server error \(statusCode)")
        }
    }
    
    private func receiveWebSocketMessage(_ webSocketTask: URLSessionWebSocketTask) {
        webSocketTask.receive { result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    print("Received binary message: \(data)")
                case .string(let text):
                    print("Received text message: \(text)")
                @unknown default:
                    print("Unknown message type received")
                }
                // Continue receiving messages
                self.receiveWebSocketMessage(webSocketTask)
                
            case .failure(let error):
                print("WebSocket receive error: \(error.localizedDescription)")
            }
        }
    }
    
    private func startWebSocketPingTimer(_ webSocketTask: URLSessionWebSocketTask) {
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            webSocketTask.sendPing { error in
                if let error = error {
                    print("WebSocket ping error: \(error.localizedDescription)")
                }
            }
        }
    }
}