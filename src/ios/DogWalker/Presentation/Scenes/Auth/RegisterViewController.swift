// UIKit framework - Latest
import UIKit

/// RegisterViewController: Manages the user interface and interactions for the registration screen
/// Requirements addressed:
/// - User Management (1.3 Scope/Core Features/User Management): Supports user registration and profile creation for dog owners and walkers
class RegisterViewController: UIViewController {
    
    // MARK: - Human Tasks
    /*
    1. Review and adjust UI layout constraints for different screen sizes
    2. Verify keyboard handling and text field scrolling behavior
    3. Test VoiceOver accessibility for all UI elements
    4. Configure proper input validation rules for phone number format
    */
    
    // MARK: - Properties
    
    private let viewModel: RegisterViewModel
    
    // MARK: - UI Components
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Full Name"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .words
        textField.accessibilityLabel = "Full Name"
        return textField
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.accessibilityLabel = "Email Address"
        return textField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.accessibilityLabel = "Password"
        return textField
    }()
    
    private lazy var phoneNumberTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Phone Number"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .phonePad
        textField.accessibilityLabel = "Phone Number"
        return textField
    }()
    
    private lazy var roleSegmentedControl: UISegmentedControl = {
        let items = ["Owner", "Walker"]
        let control = UISegmentedControl(items: items)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.accessibilityLabel = "Select Role"
        return control
    }()
    
    private lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .primaryColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        button.accessibilityLabel = "Register Button"
        return button
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Initialization
    
    init(viewModel: RegisterViewModel) {
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
        setupBindings()
        setupKeyboardHandling()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .backgroundColor
        title = "Register"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [nameTextField, emailTextField, passwordTextField, phoneNumberTextField,
         roleSegmentedControl, registerButton, activityIndicator].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            emailTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            phoneNumberTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            phoneNumberTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            phoneNumberTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            phoneNumberTextField.heightAnchor.constraint(equalToConstant: 44),
            
            roleSegmentedControl.topAnchor.constraint(equalTo: phoneNumberTextField.bottomAnchor, constant: 16),
            roleSegmentedControl.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            roleSegmentedControl.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            roleSegmentedControl.heightAnchor.constraint(equalToConstant: 44),
            
            registerButton.topAnchor.constraint(equalTo: roleSegmentedControl.bottomAnchor, constant: 32),
            registerButton.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            registerButton.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            registerButton.heightAnchor.constraint(equalToConstant: 44),
            registerButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            activityIndicator.centerXAnchor.constraint(equalTo: registerButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: registerButton.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        // Observe loading state
        viewModel.$isLoading.sink { [weak self] isLoading in
            DispatchQueue.main.async {
                self?.updateLoadingState(isLoading)
            }
        }.store(in: &viewModel.cancellables)
        
        // Observe error messages
        viewModel.$errorMessage.sink { [weak self] message in
            if let message = message {
                self?.presentAlert(title: "Error", message: message)
            }
        }.store(in: &viewModel.cancellables)
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(keyboardWillShow),
                                             name: UIResponder.keyboardWillShowNotification,
                                             object: nil)
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(keyboardWillHide),
                                             name: UIResponder.keyboardWillHideNotification,
                                             object: nil)
    }
    
    // MARK: - Actions
    
    @objc private func registerButtonTapped() {
        Logger.info("Registration process started")
        
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let password = passwordTextField.text,
              let phoneNumber = phoneNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            presentAlert(title: "Error", message: "Please fill in all fields")
            return
        }
        
        let role = roleSegmentedControl.selectedSegmentIndex == 0 ? "owner" : "walker"
        
        viewModel.registerUser(
            name: name,
            email: email,
            password: password,
            phoneNumber: phoneNumber,
            role: role
        )
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    // MARK: - Helper Methods
    
    private func updateLoadingState(_ isLoading: Bool) {
        registerButton.isEnabled = !isLoading
        if isLoading {
            activityIndicator.startAnimating()
            registerButton.setTitle("", for: .normal)
        } else {
            activityIndicator.stopAnimating()
            registerButton.setTitle("Register", for: .normal)
        }
    }
}