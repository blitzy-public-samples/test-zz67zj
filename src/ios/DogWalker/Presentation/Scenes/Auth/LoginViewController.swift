// UIKit framework - Latest
import UIKit

/// LoginViewController: Manages the user interface and interactions for the login screen
/// Requirements addressed:
/// - User Management (1.3 Scope/Core Features/User Management): Supports user authentication and login processes
class LoginViewController: UIViewController {
    
    // MARK: - Human Tasks
    /*
    1. Review accessibility labels and traits for UI elements
    2. Test VoiceOver navigation flow
    3. Verify keyboard handling behavior on different device sizes
    4. Test network error scenarios with different connection types
    */
    
    // MARK: - UI Properties
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.borderStyle = .roundedRect
        textField.accessibilityIdentifier = "loginEmailTextField"
        return textField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.accessibilityIdentifier = "loginPasswordTextField"
        return textField
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .primaryColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(handleLoginButtonTap), for: .touchUpInside)
        button.accessibilityIdentifier = "loginButton"
        return button
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Dependencies
    
    private let viewModel: LoginViewModel
    private let reachabilityUtility: ReachabilityUtility
    
    // MARK: - Initialization
    
    init(viewModel: LoginViewModel, reachabilityUtility: ReachabilityUtility) {
        self.viewModel = viewModel
        self.reachabilityUtility = reachabilityUtility
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
        setupBindings()
        setupReachability()
        
        Logger.log("LoginViewController initialized", level: .info)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .backgroundColor
        
        // Add subviews
        [emailTextField, passwordTextField, loginButton, activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Email TextField
            emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Password TextField
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Login Button
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 24),
            loginButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Activity Indicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16)
        ])
    }
    
    private func setupBindings() {
        // Observe loading state
        viewModel.$isLoading.sink { [weak self] isLoading in
            DispatchQueue.main.async {
                self?.updateLoadingState(isLoading)
            }
        }.store(in: &viewModel.cancellables)
        
        // Observe login state
        viewModel.$isLoggedIn.sink { [weak self] isLoggedIn in
            if isLoggedIn {
                self?.handleLoginSuccess()
            }
        }.store(in: &viewModel.cancellables)
        
        // Observe error messages
        viewModel.$errorMessage.sink { [weak self] errorMessage in
            if let error = errorMessage {
                self?.handleLoginError(error)
            }
        }.store(in: &viewModel.cancellables)
    }
    
    private func setupReachability() {
        reachabilityUtility.initializeReachability { [weak self] connection in
            self?.handleNetworkChange(connection)
        }
    }
    
    // MARK: - Action Handlers
    
    @objc private func handleLoginButtonTap() {
        guard validateInput() else { return }
        
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        viewModel.login(email: email, password: password)
    }
    
    func handleNetworkChange(_ connection: Reachability.Connection) {
        switch connection {
        case .unavailable:
            presentAlert(
                title: "Network Error",
                message: "Please check your internet connection and try again."
            )
            Logger.log("Network became unavailable", level: .warning)
            
        case .wifi, .cellular:
            Logger.log("Network connection established: \(connection)", level: .info)
            
        @unknown default:
            Logger.log("Unknown network status received", level: .warning)
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func validateInput() -> Bool {
        guard let email = emailTextField.text, !email.isEmpty else {
            presentAlert(title: "Error", message: "Please enter your email address.")
            return false
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            presentAlert(title: "Error", message: "Please enter your password.")
            return false
        }
        
        return true
    }
    
    private func updateLoadingState(_ isLoading: Bool) {
        loginButton.isEnabled = !isLoading
        emailTextField.isEnabled = !isLoading
        passwordTextField.isEnabled = !isLoading
        
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    private func handleLoginSuccess() {
        Logger.log("Login successful, transitioning to home screen", level: .info)
        // Note: Navigation to home screen should be handled by the coordinator pattern
        // or navigation service in a production implementation
    }
    
    private func handleLoginError(_ error: String) {
        presentAlert(title: "Login Failed", message: error)
        Logger.log("Login failed: \(error)", level: .error)
    }
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            textField.resignFirstResponder()
            handleLoginButtonTap()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}