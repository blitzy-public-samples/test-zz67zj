// UIKit - Latest
import UIKit

// MARK: - Human Tasks
/*
Prerequisites:
1. Verify proper Auto Layout constraints are maintained when testing on different device sizes
2. Test table view scrolling performance with large datasets
3. Ensure proper error handling and retry mechanisms for failed data fetches
4. Test view controller lifecycle with different navigation patterns
*/

/// HomeViewController: Manages the Home screen interface and user interactions
/// Requirements addressed:
/// - User Management (1.3 Scope/Core Features/User Management): Supports user profile management and role-based access
/// - Booking System (1.3 Scope/Core Features/Booking System): Supports booking management and schedule coordination
/// - Service Execution (1.3 Scope/Core Features/Service Execution): Displays live GPS tracking and walk details
class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .backgroundColor
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let viewModel: HomeViewModel
    
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .primaryColor
        return refreshControl
    }()
    
    // MARK: - Initialization
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        bindViewModel()
        
        // Initial data fetch
        viewModel.fetchBookings()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .backgroundColor
        title = "Home"
        
        // Add table view to view hierarchy
        view.addSubview(tableView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Table View Setup
    
    func setupTableView() {
        // Register cell types
        tableView.register(BookingCell.self, forCellReuseIdentifier: "BookingCell")
        tableView.register(DogCell.self, forCellReuseIdentifier: "DogCell")
        tableView.register(WalkCell.self, forCellReuseIdentifier: "WalkCell")
        
        // Set delegates
        tableView.delegate = self
        tableView.dataSource = self
        
        // Add refresh control
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    // MARK: - View Model Binding
    
    func bindViewModel() {
        // Observe bookings changes
        viewModel.onBookingsChanged = { [weak self] bookings in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        // Observe loading state
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                }
            }
        }
        
        // Observe errors
        viewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.presentAlert(
                    title: "Error",
                    message: error.localizedDescription
                )
            }
        }
    }
    
    // MARK: - User Actions
    
    @objc private func handleRefresh() {
        viewModel.fetchBookings()
    }
    
    func handleBookingSelection(_ indexPath: IndexPath) {
        // Get selected booking
        let booking = viewModel.bookings[indexPath.row]
        
        // Navigate to booking details
        // Note: Navigation implementation would be handled by the coordinator pattern
        Logger.debug("Selected booking: \(booking.id)")
    }
}

// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.bookings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let booking = viewModel.bookings[indexPath.row]
        
        switch booking.status {
        case "scheduled":
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookingCell", for: indexPath) as! BookingCell
            cell.configure(with: booking)
            return cell
            
        case "in_progress":
            let cell = tableView.dequeueReusableCell(withIdentifier: "WalkCell", for: indexPath) as! WalkCell
            if let walk = booking.walk {
                cell.configure(with: walk)
            }
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookingCell", for: indexPath) as! BookingCell
            cell.configure(with: booking)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        handleBookingSelection(indexPath)
    }
}

// MARK: - Theme Updates

extension HomeViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            view.backgroundColor = .backgroundColor
            tableView.backgroundColor = .backgroundColor
        }
    }
}