// CoreLocation framework - Latest
import CoreLocation
// Foundation framework - Latest
import Foundation

// Human Tasks:
// 1. Configure location services in Info.plist with proper usage descriptions
// 2. Set up proper error handling for location tracking failures
// 3. Review and implement proper data retention policies for location data
// 4. Configure network security settings for location data transmission
// 5. Test location tracking behavior under different network conditions

/// LocationService: Manages real-time location tracking and updates for the DogWalker application
/// Requirement: Service Execution (1.3 Scope/Core Features/Service Execution)
/// Supports live GPS tracking, route recording, and location-based features during dog walking sessions
class LocationService: NSObject, CLLocationManagerDelegate {
    
    // MARK: - Properties
    
    /// Flag indicating if location tracking is active
    private(set) var isTracking: Bool = false
    
    /// Current location of the user
    private(set) var currentLocation: Location?
    
    /// Location manager for GPS tracking
    private let locationManager: CLLocationManager
    
    /// WebSocket client for real-time location updates
    private let webSocketClient: WebSocketClient
    
    /// Use case for tracking location data
    private let trackLocationUseCase: TrackLocationUseCase
    
    /// Reachability utility for network monitoring
    private let reachabilityUtility: Reachability
    
    // MARK: - Initialization
    
    override init() {
        // Initialize dependencies
        self.locationManager = CLLocationManager()
        self.webSocketClient = WebSocketClient()
        self.trackLocationUseCase = TrackLocationUseCase()
        self.reachabilityUtility = Reachability.shared
        
        super.init()
        
        // Configure location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.distanceFilter = 10 // Update every 10 meters
        
        Logger.info("LocationService initialized")
    }
    
    // MARK: - Public Methods
    
    /// Starts real-time location tracking and initializes necessary services
    func startTracking() {
        guard !isTracking else {
            Logger.warning("Location tracking is already active")
            return
        }
        
        Logger.info("Starting location tracking")
        
        // Initialize network monitoring
        reachabilityUtility.startReachabilityMonitoring()
        
        // Check network connectivity
        if reachabilityUtility.isNetworkReachable() {
            Logger.info("Network is reachable, connecting WebSocket")
            webSocketClient.connect(endpoint: "/ws/location")
        } else {
            Logger.warning("Network is not reachable, location updates will be queued")
        }
        
        // Request location permissions if needed
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .restricted, .denied:
            Logger.error("Location services are not authorized")
            return
        default:
            break
        }
        
        // Start location updates
        locationManager.startUpdatingLocation()
        isTracking = true
        
        Logger.info("Location tracking started successfully")
    }
    
    /// Stops real-time location tracking and cleans up resources
    func stopTracking() {
        guard isTracking else {
            Logger.warning("Location tracking is not active")
            return
        }
        
        Logger.info("Stopping location tracking")
        
        // Stop location updates
        locationManager.stopUpdatingLocation()
        
        // Disconnect WebSocket
        webSocketClient.disconnect()
        
        // Stop network monitoring
        reachabilityUtility.stopReachabilityMonitoring()
        
        isTracking = false
        currentLocation = nil
        
        Logger.info("Location tracking stopped successfully")
    }
    
    /// Processes a new location update and sends it to the server
    /// - Parameter location: The new location to process
    func updateLocation(_ location: Location) {
        guard isTracking else {
            Logger.warning("Cannot update location - tracking is not active")
            return
        }
        
        Logger.info("Processing location update: \(location)")
        
        // Update current location
        currentLocation = location
        
        // Save location using use case
        trackLocationUseCase.trackLocation(
            latitude: location.latitude,
            longitude: location.longitude
        )
        
        // Send location update via WebSocket if connected
        if reachabilityUtility.isNetworkReachable() {
            let locationData: [String: Any] = [
                "latitude": location.latitude,
                "longitude": location.longitude,
                "timestamp": DateFormatter.stringFromDate(Date())
            ]
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: locationData),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                webSocketClient.sendMessage(jsonString)
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let clLocation = locations.last else { return }
        
        // Create Location entity from CLLocation
        let location = Location(
            latitude: clLocation.coordinate.latitude,
            longitude: clLocation.coordinate.longitude
        )
        
        // Process location update
        updateLocation(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Logger.error("Location manager error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            if isTracking {
                manager.startUpdatingLocation()
            }
        case .denied, .restricted:
            stopTracking()
            Logger.error("Location services authorization denied")
        default:
            break
        }
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension LocationService {
    /// Simulates a location update for testing
    func simulateLocationUpdate(latitude: Double, longitude: Double) {
        Logger.debug("Simulating location update")
        let location = Location(latitude: latitude, longitude: longitude)
        updateLocation(location)
    }
    
    /// Tests location tracking with logging
    func testLocationTracking() {
        Logger.debug("Testing location tracking")
        startTracking()
        
        // Simulate a location update after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.simulateLocationUpdate(latitude: 37.7749, longitude: -122.4194)
        }
    }
}
#endif