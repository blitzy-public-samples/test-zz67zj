// UIKit version: Latest
import UIKit

// Internal dependencies using relative paths
import "../../../Presentation/Common/Extensions/UIViewController+Alert"

// MARK: - Human Tasks
/*
Prerequisites:
1. Verify UI layout constraints meet accessibility guidelines
2. Test form validation with VoiceOver enabled
3. Review error message strings for localization
4. Ensure keyboard handling and input field navigation is properly configured
*/

/// ViewController for adding a new dog to the system
/// Requirement: Dog Profile Management (1.3 Scope/Core Features/User Management)
/// Supports the creation of dog profiles with details like breed, age, and special needs
class AddDogViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: AddDogViewModel
    
    // MARK: - UI Elements
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Dog's Name"
        textField.borderStyle = .roundedRect
        textField.accessibilityLabel = "Dog's Name"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var breedTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Breed"
        textField.borderStyle = .roundedRect
        textField.accessibilityLabel = "Dog's Breed"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var ageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Age"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.accessibilityLabel = "Dog's Age"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var addDogButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Dog", for: .normal)
        button.backgroundColor = .primaryColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Initialization
    
    init(viewModel: AddDogViewModel) {
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
        setupActions()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "Add Dog"
        view.backgroundColor = .backgroundColor
        
        // Add subviews
        view.addSubview(nameTextField)
        view.addSubview(breedTextField)
        view.addSubview(ageTextField)
        view.addSubview(addDogButton)
        view.addSubview(loadingIndicator)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            breedTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            breedTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            breedTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            breedTextField.heightAnchor.constraint(equalToConstant: 44),
            
            ageTextField.topAnchor.constraint(equalTo: breedTextField.bottomAnchor, constant: 16),
            ageTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            ageTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            ageTextField.heightAnchor.constraint(equalToConstant: 44),
            
            addDogButton.topAnchor.constraint(equalTo: ageTextField.bottomAnchor, constant: 32),
            addDogButton.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            addDogButton.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            addDogButton.heightAnchor.constraint(equalToConstant: 50),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        // Bind to view model's loading state
        viewModel.$isLoading.sink { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                    self?.addDogButton.isEnabled = false
                } else {
                    self?.loadingIndicator.stopAnimating()
                    self?.addDogButton.isEnabled = true
                }
            }
        }.store(in: &cancellables)
        
        // Bind to view model's error message
        viewModel.$errorMessage.sink { [weak self] errorMessage in
            if let errorMessage = errorMessage {
                self?.presentAlert(
                    title: "Error",
                    message: errorMessage
                )
            }
        }.store(in: &cancellables)
    }
    
    private func setupActions() {
        addDogButton.addTarget(
            self,
            action: #selector(onAddDogButtonTapped),
            for: .touchUpInside
        )
    }
    
    // MARK: - Actions
    
    @objc private func onAddDogButtonTapped() {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let breed = breedTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let ageText = ageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let age = Int(ageText) else {
            presentAlert(
                title: "Invalid Input",
                message: "Please fill in all fields correctly. Age must be a number."
            )
            return
        }
        
        // Get the current user's ID (In a real app, this would come from a user session)
        let ownerId = "current_user_id"
        
        viewModel.addDog(
            name: name,
            breed: breed,
            age: age,
            ownerId: ownerId
        )
    }
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - UITextFieldDelegate

extension AddDogViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTextField:
            breedTextField.becomeFirstResponder()
        case breedTextField:
            ageTextField.becomeFirstResponder()
        case ageTextField:
            ageTextField.resignFirstResponder()
            onAddDogButtonTapped()
        default:
            break
        }
        return true
    }
}