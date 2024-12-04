// UIKit version: Latest
import UIKit
import Foundation

/// A custom UIButton subclass that includes a loading spinner and supports theming
/// Requirements addressed: 8.1.2 Interface Elements - Provides a reusable button component with a loading state
class LoadingButton: UIButton {
    
    // MARK: - Private Properties
    
    private let spinner: UIActivityIndicatorView = {
        if #available(iOS 13.0, *) {
            return UIActivityIndicatorView(style: .medium)
        } else {
            return UIActivityIndicatorView(style: .gray)
        }
    }()
    
    private var originalButtonText: String?
    
    // MARK: - Public Properties
    
    /// Indicates whether the button is currently in a loading state
    public private(set) var isLoading: Bool = false
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    // MARK: - Private Setup Methods
    
    private func setupButton() {
        // Configure button appearance
        backgroundColor = .primaryColor
        setTitleColor(.textColor, for: .normal)
        layer.cornerRadius = 8
        clipsToBounds = true
        
        // Configure spinner
        spinner.hidesWhenStopped = true
        spinner.color = .textColor
        addSubview(spinner)
        
        // Center spinner in button
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        Logger.debug("LoadingButton initialized with default configuration")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Ensure spinner remains centered when button size changes
        spinner.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    // MARK: - Public Methods
    
    /// Updates the button's state to show or hide the loading spinner
    /// - Parameter loading: Boolean indicating whether the button should show loading state
    public func setLoading(_ loading: Bool) {
        isLoading = loading
        
        if loading {
            originalButtonText = title(for: .normal)
            setTitle("", for: .normal)
            spinner.startAnimating()
            isEnabled = false
            
            Logger.info("LoadingButton entered loading state")
        } else {
            setTitle(originalButtonText, for: .normal)
            spinner.stopAnimating()
            isEnabled = true
            
            Logger.info("LoadingButton exited loading state")
        }
        
        // Ensure proper layout after state change
        layoutIfNeeded()
    }
    
    // MARK: - State Management
    
    override var isHighlighted: Bool {
        didSet {
            // Adjust opacity when button is pressed
            alpha = isHighlighted ? 0.8 : 1.0
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            // Adjust opacity when button is disabled
            alpha = isEnabled ? 1.0 : 0.6
        }
    }
}