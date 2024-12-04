// Foundation framework - Latest version
import Foundation

// MARK: - Human Tasks
/*
Prerequisites:
1. Configure location services in Info.plist with proper usage descriptions
2. Set up proper error handling for location tracking failures
3. Review and implement proper data retention policies for walk data compliance
4. Configure proper notifications for walk status updates
*/

/// ActiveWalkViewModel: Manages the state and business logic for the Active Walk screen
/// Requirement: Service Execution (1.3 Scope/Core Features/Service Execution)
/// Supports live GPS tracking, route recording, and status updates for dog walking sessions
class ActiveWalkViewModel {
    
    // MARK: - Properties
    
    /// Current walk session identifier
    private(set) var currentWalkId: String?
    
    /// Dependencies for walk management
    private let startWalkUseCase: StartWalkUseCase
    private let endWalkUseCase: EndWalkUseCase
    private let trackWalkUseCase: TrackWalkUseCase
    private let locationService: LocationService
    private let notificationService: NotificationService
    
    // MARK: - Initialization
    
    /// Initializes the view model with required dependencies
    /// - Parameters:
    ///   - startWalkUseCase: Use case for starting walks
    ///   - endWalkUseCase: Use case for ending walks
    ///   - trackWalkUseCase: Use case for tracking walk locations
    ///   - locationService: Service for location tracking
    ///   - notificationService: Service for sending notifications
    init(
        startWalkUseCase: StartWalkUseCase,
        endWalkUseCase: EndWalkUseCase,
        trackWalkUseCase: TrackWalkUseCase,
        locationService: LocationService,
        notificationService: NotificationService
    ) {
        self.startWalkUseCase = startWalkUseCase
        self.endWalkUseCase = endWalkUseCase
        self.trackWalkUseCase = trackWalkUseCase
        self.locationService = locationService
        self.notificationService = notificationService
        
        Logger.info("ActiveWalkViewModel initialized")
    }
    
    // MARK: - Walk Management
    
    /// Starts a new walk session
    /// - Parameters:
    ///   - walker: The user conducting the walk
    ///   - dogs: Array of dogs participating in the walk
    ///   - startLocation: The starting location of the walk
    func startWalk(walker: User, dogs: [Dog], startLocation: Location) {
        Logger.info("Starting walk session for walker: \(walker.id) with \(dogs.count) dogs")
        
        do {
            // Start the walk using the use case
            let walk = try startWalkUseCase.startWalk(
                walker: walker,
                dogs: dogs,
                startLocation: startLocation
            )
            
            // Store the walk ID
            currentWalkId = walk.id
            
            // Start location tracking
            locationService.startTracking()
            
            // Send notification to owner
            notificationService.sendPushNotification(
                userId: dogs.first?.ownerId ?? "",
                message: "Your dog's walk has started!"
            )
            
            Logger.info("Walk session started successfully with ID: \(walk.id)")
            
        } catch {
            Logger.error("Failed to start walk: \(error.localizedDescription)")
            handleError(error)
        }
    }
    
    /// Ends the current walk session
    func endWalk() {
        Logger.info("Ending walk session")
        
        guard let walkId = currentWalkId else {
            Logger.error("No active walk session found")
            return
        }
        
        do {
            // Stop location tracking
            locationService.stopTracking()
            
            // End the walk using the use case
            try endWalkUseCase.endWalk(Walk(
                id: walkId,
                walker: User(id: "", name: "", email: "", phone: "", role: "", walks: [], payments: [], currentLocation: Location(latitude: 0, longitude: 0)),
                dogs: [],
                booking: Booking(id: "", owner: User(id: "", name: "", email: "", phone: "", role: "", walks: [], payments: [], currentLocation: Location(latitude: 0, longitude: 0)), walker: User(id: "", name: "", email: "", phone: "", role: "", walks: [], payments: [], currentLocation: Location(latitude: 0, longitude: 0)), dogs: [], walk: WalkSummary(id: "", distance: 0, startTime: Date(), endTime: Date()), payment: PaymentSummary(id: "", amount: 0, currency: ""), scheduledAt: Date(), status: ""),
                route: [],
                startTime: Date(),
                endTime: Date(),
                status: "in_progress"
            ))
            
            // Send notification to owner
            notificationService.sendPushNotification(
                userId: "", // Should be retrieved from the walk entity
                message: "Your dog's walk has ended!"
            )
            
            // Clear the current walk ID
            currentWalkId = nil
            
            Logger.info("Walk session ended successfully")
            
        } catch {
            Logger.error("Failed to end walk: \(error.localizedDescription)")
            handleError(error)
        }
    }
    
    /// Tracks the real-time location during the walk
    /// - Parameters:
    ///   - latitude: Current latitude coordinate
    ///   - longitude: Current longitude coordinate
    func trackLocation(latitude: Double, longitude: Double) {
        guard let walkId = currentWalkId else {
            Logger.error("No active walk session found")
            return
        }
        
        // Validate coordinates
        guard latitude >= -90 && latitude <= 90 &&
              longitude >= -180 && longitude <= 180 else {
            Logger.error("Invalid coordinates provided: lat=\(latitude), lon=\(longitude)")
            return
        }
        
        Logger.info("Tracking location for walk \(walkId): lat=\(latitude), lon=\(longitude)")
        
        // Track location using the use case
        trackWalkUseCase.trackLocation(
            walkId: walkId,
            latitude: latitude,
            longitude: longitude
        )
        
        // Update location service
        locationService.updateLocation(Location(
            latitude: latitude,
            longitude: longitude
        ))
    }
    
    // MARK: - Error Handling
    
    /// Handles errors that occur during walk management
    /// - Parameter error: The error to handle
    private func handleError(_ error: Error) {
        // Log the error
        Logger.error("ActiveWalkViewModel error: \(error.localizedDescription)")
        
        // Clean up resources if needed
        if error is StartWalkUseCase.Error {
            currentWalkId = nil
            locationService.stopTracking()
        }
        
        // Present error to user (should be handled by the view controller)
        // This is just a placeholder for the actual error handling implementation
        if let topViewController = UIApplication.shared.keyWindow?.rootViewController {
            topViewController.presentAlert(
                title: "Walk Error",
                message: "An error occurred: \(error.localizedDescription)"
            )
        }
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension ActiveWalkViewModel {
    /// Simulates a walk session for testing
    func simulateWalkSession() {
        Logger.debug("Simulating walk session")
        
        // Create test data
        let walker = User(
            id: "test-walker",
            name: "Test Walker",
            email: "walker@test.com",
            phone: "1234567890",
            role: "walker",
            walks: [],
            payments: [],
            currentLocation: Location(latitude: 37.7749, longitude: -122.4194)
        )
        
        let dog = Dog(
            id: "test-dog",
            name: "Test Dog",
            breed: "Test Breed",
            age: 3,
            ownerId: "test-owner"
        )
        
        let startLocation = Location(latitude: 37.7749, longitude: -122.4194)
        
        // Start test walk
        startWalk(walker: walker, dogs: [dog], startLocation: startLocation)
        
        // Simulate location updates
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.trackLocation(latitude: 37.7750, longitude: -122.4195)
        }
        
        // End test walk after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.endWalk()
        }
    }
}
#endif