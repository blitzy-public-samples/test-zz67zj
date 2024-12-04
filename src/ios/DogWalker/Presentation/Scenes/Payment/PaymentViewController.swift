// UIKit - Latest version
import UIKit

// MARK: - Human Tasks
/*
Prerequisites:
1. Ensure PaymentViewModel is properly configured with payment gateway credentials
2. Verify proper error handling and user feedback mechanisms are in place
3. Test accessibility features and VoiceOver support
4. Verify proper keyboard handling for payment input fields
*/

/// PaymentViewController: Manages the UI and user interactions for the Payment screen
/// Requirements addressed:
/// - Payments (1.3 Scope/Core Features/Payments): Supports secure payment processing, automated billing, and receipt generation
/// - User Interface Design (8.1.1 Design Specifications): Ensures a responsive and accessible UI for payment processing
final class PaymentViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: PaymentViewModel
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .backgroundColor
        table.separatorStyle = .singleLine
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 80
        return table
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .primaryColor
        return indicator
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    // MARK: - Initialization
    
    init(viewModel: PaymentViewModel) {
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
        bindViewModel()
        
        Logger.log("Payment screen initialized", level: .info)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .backgroundColor
        
        // Configure navigation bar
        title = "Payment"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Configure table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PaymentCell.self, forCellReuseIdentifier: "PaymentCell")
        
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
            
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            errorLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8)
        ])
        
        // Setup accessibility
        setupAccessibility()
    }
    
    private func setupAccessibility() {
        tableView.accessibilityLabel = "Payment details"
        tableView.accessibilityHint = "Shows payment information and status"
        
        loadingIndicator.accessibilityLabel = "Processing payment"
        loadingIndicator.accessibilityTraits = .updatesFrequently
    }
    
    // MARK: - View Model Binding
    
    private func bindViewModel() {
        // Observe loading state
        viewModel.isProcessing.publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isProcessing in
                self?.updateLoadingState(isProcessing)
            }
            .store(in: &cancellables)
        
        // Observe error messages
        viewModel.errorMessage.publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.updateErrorState(errorMessage)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - UI Updates
    
    private func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
            tableView.isUserInteractionEnabled = false
            UIAccessibility.post(notification: .announcement, argument: "Processing payment")
        } else {
            loadingIndicator.stopAnimating()
            tableView.isUserInteractionEnabled = true
        }
    }
    
    private func updateErrorState(_ errorMessage: String?) {
        errorLabel.text = errorMessage
        errorLabel.isHidden = errorMessage == nil
        
        if let error = errorMessage {
            UIAccessibility.post(notification: .announcement, argument: "Payment error: \(error)")
        }
    }
    
    // MARK: - Payment Processing
    
    func processPayment(_ payment: Payment) {
        Logger.log("Processing payment: \(payment.id)", level: .info)
        
        viewModel.processPayment(payment)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension PaymentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // Assuming one payment per screen
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as? PaymentCell else {
            return UITableViewCell()
        }
        
        if let payment = viewModel.currentPayment {
            cell.configure(with: payment)
        }
        
        return cell
    }
}

// MARK: - Memory Management

extension PaymentViewController {
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        cancellables.removeAll()
        Logger.log("PaymentViewController deallocated", level: .debug)
    }
}