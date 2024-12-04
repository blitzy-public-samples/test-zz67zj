// UIKit framework - Latest
import UIKit

// MARK: - Human Tasks
/*
Prerequisites:
1. Ensure proper UI layout constraints are configured in Interface Builder
2. Verify accessibility labels and hints are properly set for UI elements
3. Review error messages for localization requirements
4. Configure proper analytics tracking for profile actions
*/

/// ProfileViewController manages the user interface for the Profile screen
/// Requirements addressed:
/// - User Management (1.3 Scope/Core Features/User Management): Supports user profile management
/// - User Interface Design (8.1.1 Design Specifications/Accessibility): Ensures accessible UI
/// - Centralized Logging (7.4.1 Monitoring and Observability): Implements consistent logging
class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: ProfileViewModel
    private let saveButton: LoadingButton
    
    // MARK: - UI Elements
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Full Name"
        textField.borderStyle = .roundedRect
        textField.accessibilityLabel = "Full Name Input Field"
        return textField
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.accessibilityLabel = "Email Input Field"
        return textField
    }()
    
    private lazy var phoneTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Phone Number"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .phonePad
        textField.accessibilityLabel = "Phone Number Input Field"
        return textField
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(onLogoutButtonTapped), for: .touchUpInside)
        button.accessibilityLabel = "Logout Button"
        return button
    }()
    
    // MARK: - Initialization
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        self.saveButton = LoadingButton(frame: .zero)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Logger.info("ProfileViewController - View did load")
        
        setupUI()
        setupConstraints()
        bindViewModel()
        
        // Fetch user profile data
        if let userId = viewModel.user?.id {
            viewModel.fetchUserProfile(userId: userId)
        }
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .backgroundColor
        title = "Profile"
        
        // Configure save button
        saveButton.setTitle("Save Changes", for: .normal)
        saveButton.addTarget(self, action: #selector(onSaveButtonTapped), for: .touchUpInside)
        saveButton.accessibilityLabel = "Save Changes Button"
        
        // Add UI elements to view hierarchy
        [nameTextField, emailTextField, phoneTextField, saveButton, logoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Name text field constraints
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Email text field constraints
            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            emailTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Phone text field constraints
            phoneTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            phoneTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            phoneTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            phoneTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Save button constraints
            saveButton.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 32),
            saveButton.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Logout button constraints
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - ViewModel Binding
    
    private func bindViewModel() {
        // Update UI with user data when available
        if let user = viewModel.user {
            nameTextField.text = user.name
            emailTextField.text = user.email
            phoneTextField.text = user.phone
        }
    }
    
    // MARK: - Action Handlers
    
    @objc private func onSaveButtonTapped() {
        Logger.info("ProfileViewController - Save button tapped")
        
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let phone = phoneTextField.text, !phone.isEmpty,
              let currentUser = viewModel.user else {
            presentAlert(
                title: "Validation Error",
                message: "Please fill in all fields"
            )
            return
        }
        
        // Show loading state
        saveButton.setLoading(true)
        
        // Create updated user object
        let updatedUser = User(
            id: currentUser.id,
            name: name,
            email: email,
            phone: phone,
            role: currentUser.role,
            walks: currentUser.walks,
            payments: currentUser.payments,
            currentLocation: currentUser.currentLocation
        )
        
        // Update user profile
        viewModel.updateUserProfile(user: updatedUser)
        
        // Handle success/failure
        if viewModel.errorMessage == nil {
            presentAlert(
                title: "Success",
                message: "Profile updated successfully"
            )
        } else {
            presentAlert(
                title: "Error",
                message: viewModel.errorMessage ?? "Failed to update profile"
            )
        }
        
        // Hide loading state
        saveButton.setLoading(false)
    }
    
    @objc private func onLogoutButtonTapped() {
        Logger.info("ProfileViewController - Logout button tapped")
        
        presentConfirmationAlert(
            title: "Confirm Logout",
            message: "Are you sure you want to logout?"
        ) { [weak self] _ in
            guard let self = self else { return }
            
            if self.viewModel.logout() {
                // Navigate to login screen
                // Note: This should be handled by the coordinator/navigation layer
                Logger.info("ProfileViewController - User logged out successfully")
            } else {
                self.presentAlert(
                    title: "Error",
                    message: "Failed to logout. Please try again."
                )
            }
        }
    }
}