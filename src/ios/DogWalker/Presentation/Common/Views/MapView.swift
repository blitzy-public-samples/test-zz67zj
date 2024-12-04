// MapKit framework - Latest
import MapKit
// Foundation framework - Latest
import Foundation

// Human Tasks:
// 1. Configure location services in Info.plist with proper usage descriptions
// 2. Set up proper error handling for location tracking failures
// 3. Review and implement proper data retention policies for location data
// 4. Configure network security settings for location data transmission
// 5. Test map behavior under different network conditions

/// MapView: A reusable component for displaying and interacting with maps
/// Requirement: Service Execution (1.3 Scope/Core Features/Service Execution)
/// Supports live GPS tracking, route recording, and location-based features during dog walking sessions
class MapView: UIView {
    
    // MARK: - Properties
    
    /// The underlying MKMapView instance
    private let mapView: MKMapView
    
    /// Current location being displayed on the map
    private var currentLocation: Location?
    
    /// Location service for tracking updates
    private let locationService: LocationService
    
    /// WebSocket client for real-time updates
    private let webSocketClient: WebSocketClient
    
    /// Route overlay currently displayed on the map
    private var routeOverlay: MKPolyline?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        // Initialize map view
        self.mapView = MKMapView(frame: .zero)
        self.locationService = LocationService()
        self.webSocketClient = WebSocketClient()
        
        super.init(frame: frame)
        
        setupMapView()
        initializeMap()
        
        Logger.info("MapView initialized")
    }
    
    required init?(coder: NSCoder) {
        // Initialize map view
        self.mapView = MKMapView(frame: .zero)
        self.locationService = LocationService()
        self.webSocketClient = WebSocketClient()
        
        super.init(coder: coder)
        
        setupMapView()
        initializeMap()
        
        Logger.info("MapView initialized from coder")
    }
    
    // MARK: - Setup
    
    /// Sets up the map view with default configurations
    private func setupMapView() {
        // Add map view to view hierarchy
        addSubview(mapView)
        
        // Configure map view constraints
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    /// Initializes the map with default configurations
    func initializeMap() {
        Logger.info("Initializing map view")
        
        // Configure map view
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        // Set default map type
        mapView.mapType = .standard
        
        // Configure map camera
        let defaultZoomLevel = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        mapView.setRegion(MKCoordinateRegion(
            center: mapView.userLocation.coordinate,
            span: defaultZoomLevel
        ), animated: true)
        
        Logger.info("Map view initialized successfully")
    }
    
    // MARK: - Public Methods
    
    /// Updates the map view with the user's current location
    /// - Parameter location: The new location to display
    func updateUserLocation(_ location: Location) {
        Logger.info("Updating user location: \(location)")
        
        // Update current location
        currentLocation = location
        
        // Create coordinate from location
        let coordinate = CLLocationCoordinate2D(
            latitude: location.latitude,
            longitude: location.longitude
        )
        
        // Update map region to show new location
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        mapView.setRegion(region, animated: true)
        
        // Update location service
        locationService.updateLocation(location)
        
        // Send location update via WebSocket
        let locationData: [String: Any] = [
            "latitude": location.latitude,
            "longitude": location.longitude,
            "timestamp": DateFormatter.stringFromDate(Date())
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: locationData),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            webSocketClient.sendMessage(jsonString)
        }
        
        Logger.info("User location updated successfully")
    }
    
    /// Draws a route on the map based on a series of locations
    /// - Parameter route: Array of locations defining the route
    func drawRoute(_ route: [Location]) {
        Logger.info("Drawing route with \(route.count) points")
        
        // Remove existing route overlay
        if let existingRoute = routeOverlay {
            mapView.removeOverlay(existingRoute)
        }
        
        // Convert locations to coordinates
        let coordinates = route.map { location in
            CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            )
        }
        
        // Create and add new route overlay
        routeOverlay = MKPolyline(coordinates: coordinates, count: coordinates.count)
        if let overlay = routeOverlay {
            mapView.addOverlay(overlay)
            
            // Adjust map region to show entire route
            mapView.setVisibleMapRect(
                overlay.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50),
                animated: true
            )
        }
        
        Logger.info("Route drawn successfully")
    }
}

// MARK: - MKMapViewDelegate

extension MapView: MKMapViewDelegate {
    /// Customizes the appearance of map overlays
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 4
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    /// Handles user location updates from the map
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let location = Location(
            latitude: userLocation.coordinate.latitude,
            longitude: userLocation.coordinate.longitude
        )
        updateUserLocation(location)
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension MapView {
    /// Simulates a location update for testing
    func simulateLocationUpdate(latitude: Double, longitude: Double) {
        Logger.debug("Simulating location update")
        let location = Location(latitude: latitude, longitude: longitude)
        updateUserLocation(location)
    }
    
    /// Tests route drawing with sample data
    func testRouteDrawing() {
        Logger.debug("Testing route drawing")
        let sampleRoute = [
            Location(latitude: 37.7749, longitude: -122.4194),
            Location(latitude: 37.7750, longitude: -122.4180),
            Location(latitude: 37.7752, longitude: -122.4170)
        ]
        drawRoute(sampleRoute)
    }
}
#endif