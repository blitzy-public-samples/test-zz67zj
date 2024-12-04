// UIKit framework - Latest
import UIKit

// MARK: - Human Tasks
/*
Prerequisites:
1. Configure location services in Info.plist with proper usage descriptions
2. Set up proper error handling for location tracking failures
3. Review and implement proper data retention policies for walk data compliance
4. Configure proper notifications for walk status updates
*/

/// ActiveWalkViewController: Manages the UI and interactions for the Active Walk screen
/// Requirement: Service Execution (1.3 Scope/Core Features/Service Execution)
/// Supports live GPS tracking, route recording, and status updates for dog walking sessions
class ActiveWalkViewController: UIViewController {
    
    // MARK: - Properties
    
    private let activeWalkViewModel: ActiveWalkViewModel
    private let mapView: MapView
    private let startButton: LoadingButton
    private let endButton: LoadingButton
    
    private let locationService: LocationService
    private let notificationService: NotificationService
    
    // MARK: - UI Properties
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Initialization
    
    init() {
        self.activeWalkViewModel = ActiveWalkViewModel(
            startWalkUseCase: StartWalkUseCase(),
            endWalkUseCase: EndWalkUseCase(),
            trackWalkUseCase: TrackWalkUseCase(),
            locationService: LocationService(),
            notificationService: NotificationService()
        )
        self.mapView = MapView(frame: .zero)
        self.startButton = LoadingButton(frame: .zero)
        self.endButton = LoadingButton(frame: .zero)
        self.locationService = LocationService()
        self.notificationService = NotificationService()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupActions()
        
        // Initialize map
        mapView.initializeMap()
        
        Logger.info("ActiveWalkViewController loaded")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .backgroundColor
        
        // Configure map view
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        
        // Configure buttons
        startButton.setTitle("Start Walk", for: .normal)
        startButton.backgroundColor = .primaryColor
        
        endButton.setTitle("End Walk", for: .normal)
        endButton.backgroundColor = .accentColor
        endButton.isEnabled = false
        
        // Add buttons to stack view
        buttonStackView.addArrangedSubview(startButton)
        buttonStackView.addArrangedSubview(endButton)
        view.addSubview(buttonStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Map view constraints
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Button stack view constraints
            buttonStackView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupActions() {
        startButton.addTarget(self, action: #selector(startWalkAction), for: .touchUpInside)
        endButton.addTarget(self, action: #selector(endWalkAction), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func startWalkAction() {
        Logger.info("Starting walk")
        
        startButton.setLoading(true)
        
        // Start location tracking
        locationService.startTracking()
        
        // Start the walk using view model
        activeWalkViewModel.startWalk(
            walker: User(id: "", name: "", email: "", phone: "", role: "", walks: [], payments: [], currentLocation: Location(latitude: 0, longitude: 0)),
            dogs: [],
            startLocation: Location(latitude: 0, longitude: 0)
        )
        
        // Update UI state
        startButton.isEnabled = false
        endButton.isEnabled = true
        startButton.setLoading(false)
    }
    
    @objc private func endWalkAction() {
        Logger.info("Ending walk")
        
        endButton.setLoading(true)
        
        // Stop location tracking
        locationService.stopTracking()
        
        // End the walk using view model
        activeWalkViewModel.endWalk()
        
        // Send notification
        notificationService.sendPushNotification(
            userId: "",
            message: "Your dog's walk has ended!"
        )
        
        // Update UI state
        startButton.isEnabled = true
        endButton.isEnabled = false
        endButton.setLoading(false)
    }
    
    // MARK: - Location Updates
    
    /// Updates the user's location on the map
    /// - Parameters:
    ///   - latitude: The current latitude coordinate
    ///   - longitude: The current longitude coordinate
    func updateLocation(latitude: Double, longitude: Double) {
        Logger.info("Updating location: lat=\(latitude), lon=\(longitude)")
        
        // Track location in view model
        activeWalkViewModel.trackLocation(latitude: latitude, longitude: longitude)
        
        // Update map view
        mapView.updateUserLocation(Location(latitude: latitude, longitude: longitude))
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension ActiveWalkViewController {
    /// Simulates a walk session for testing
    func simulateWalkSession() {
        Logger.debug("Simulating walk session")
        
        // Start walk
        startWalkAction()
        
        // Simulate location updates
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.updateLocation(latitude: 37.7749, longitude: -122.4194)
        }
        
        // End walk after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.endWalkAction()
        }
    }
}
#endif