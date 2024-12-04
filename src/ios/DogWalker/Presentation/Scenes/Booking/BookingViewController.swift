// UIKit version: Latest
import UIKit

// MARK: - Human Tasks
/*
Prerequisites:
1. Verify Auto Layout constraints work correctly across different device sizes
2. Test table view scrolling performance with large datasets
3. Review accessibility labels and traits for UI elements
4. Ensure proper error handling and user feedback is implemented
*/

/// BookingViewController: Manages the Booking screen's user interface and interactions
/// Requirements addressed:
/// - Booking System (1.3 Scope/Core Features/Booking System): Supports real-time availability search, booking management, and schedule coordination
class BookingViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: BookingViewModel
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 88
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.backgroundColor = .backgroundColor
        return table
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .textColor
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    // MARK: - Initialization
    
    init(viewModel: BookingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        Logger.debug("BookingViewController initialized with viewModel")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Logger.debug("BookingViewController viewDidLoad")
        
        setupUI()
        setupTableView()
        setupBindings()
        loadBookings()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "Bookings"
        view.backgroundColor = .backgroundColor
        
        // Add subviews
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(errorLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
        
        // Setup refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BookingCell.self, forCellReuseIdentifier: "BookingCell")
    }
    
    private func setupBindings() {
        viewModel.onStateChanged = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
    }
    
    // MARK: - Data Loading
    
    private func loadBookings() {
        Logger.info("Loading bookings data")
        viewModel.loadBookings()
    }
    
    @objc private func handleRefresh() {
        Logger.info("Refreshing bookings data")
        viewModel.refresh { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    // MARK: - UI Updates
    
    private func updateUI() {
        if viewModel.isLoading {
            loadingIndicator.startAnimating()
            errorLabel.isHidden = true
            tableView.isHidden = true
        } else {
            loadingIndicator.stopAnimating()
            
            if viewModel.hasError {
                errorLabel.text = viewModel.errorMessage
                errorLabel.isHidden = false
                tableView.isHidden = true
            } else {
                errorLabel.isHidden = true
                tableView.isHidden = false
                tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension BookingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfBookings
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookingCell", for: indexPath) as? BookingCell else {
            Logger.error("Failed to dequeue BookingCell")
            return UITableViewCell()
        }
        
        if let booking = viewModel.booking(at: indexPath.row) {
            cell.configure(with: booking)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension BookingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let booking = viewModel.booking(at: indexPath.row) else {
            Logger.warning("No booking found at index \(indexPath.row)")
            return
        }
        
        Logger.info("Selected booking: \(booking.id)")
        // Note: Navigation to booking details would be implemented here
        // This would typically involve creating and presenting a BookingDetailsViewController
    }
}

// MARK: - Theme Updates

extension BookingViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            view.backgroundColor = .backgroundColor
            tableView.backgroundColor = .backgroundColor
            errorLabel.textColor = .textColor
        }
    }
}