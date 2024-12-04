// Foundation framework - Latest
import Foundation

/// APIClient: Manages network requests and responses for the Dog Walker iOS application
/// Requirements addressed:
/// - 8.3.2/API Specifications: Implements network request handling, including error handling and connectivity checks
class APIClient {
    // MARK: - Human Tasks
    /*
    1. Configure network security settings in Info.plist (NSAppTransportSecurity)
    2. Set up SSL certificate pinning for production environment
    3. Configure error tracking and monitoring service
    4. Set up network reachability monitoring
    */
    
    // MARK: - Properties
    
    /// URLSession instance for making network requests
    private let session: URLSession
    
    /// Network reachability flag
    private var isNetworkReachable: Bool {
        var flags: SCNetworkReachabilityFlags = []
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, "www.dogwalker.com") else {
            return false
        }
        SCNetworkReachabilityGetFlags(reachability, &flags)
        return flags.contains(.reachable) && !flags.contains(.connectionRequired)
    }
    
    // MARK: - Initialization
    
    /// Initializes the APIClient with a default URLSession instance
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        configuration.waitsForConnectivity = true
        
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Network Requests
    
    /// Executes a network request to the specified API endpoint
    /// - Parameters:
    ///   - endpoint: The API endpoint path
    ///   - parameters: Optional dictionary of parameters to include in the request
    ///   - completion: Completion handler with Result type containing response data or error
    func performRequest(
        endpoint: String,
        parameters: [String: Any]? = nil,
        completion: @escaping (Result<Data, APIError>) -> Void
    ) {
        // Check network connectivity
        guard isNetworkReachable else {
            let error = APIError(
                message: "No network connection available",
                statusCode: nil,
                underlyingError: nil
            )
            completion(.failure(error))
            return
        }
        
        // Construct URL using APIEndpoints
        let urlString = APIEndpoints().urlForEndpoint(endpoint)
        guard let url = URL(string: urlString) else {
            let error = APIError(
                message: "Invalid URL constructed",
                statusCode: nil,
                underlyingError: nil
            )
            completion(.failure(error))
            return
        }
        
        // Create URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = parameters != nil ? "POST" : "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add parameters to request body if present
        if let parameters = parameters {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            } catch {
                let apiError = APIError(
                    message: "Failed to serialize request parameters",
                    statusCode: nil,
                    underlyingError: error
                )
                completion(.failure(apiError))
                return
            }
        }
        
        // Perform network request
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            self.handleResponse(data: data, response: response, error: error, completion: completion)
        }
        
        task.resume()
    }
    
    // MARK: - Response Handling
    
    /// Processes the response from a network request
    /// - Parameters:
    ///   - data: Optional response data
    ///   - response: Optional URL response
    ///   - error: Optional error from the request
    ///   - completion: Completion handler with Result type containing response data or error
    private func handleResponse(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: @escaping (Result<Data, APIError>) -> Void
    ) {
        // Handle network error if present
        if let error = error {
            let apiError = APIError(
                message: "Network request failed",
                statusCode: nil,
                underlyingError: error
            )
            completion(.failure(apiError))
            return
        }
        
        // Validate HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            let error = APIError(
                message: "Invalid response type",
                statusCode: nil,
                underlyingError: nil
            )
            completion(.failure(error))
            return
        }
        
        // Handle response based on status code
        switch httpResponse.statusCode {
        case 200...299:
            if let data = data {
                completion(.success(data))
            } else {
                let error = APIError(
                    message: "No data received",
                    statusCode: httpResponse.statusCode,
                    underlyingError: nil
                )
                completion(.failure(error))
            }
            
        case 400...499:
            let error = APIError(
                message: "Client error",
                statusCode: httpResponse.statusCode,
                underlyingError: nil
            )
            completion(.failure(error))
            
        case 500...599:
            let error = APIError(
                message: "Server error",
                statusCode: httpResponse.statusCode,
                underlyingError: nil
            )
            completion(.failure(error))
            
        default:
            let error = APIError(
                message: "Unexpected status code",
                statusCode: httpResponse.statusCode,
                underlyingError: nil
            )
            completion(.failure(error))
        }
    }
}