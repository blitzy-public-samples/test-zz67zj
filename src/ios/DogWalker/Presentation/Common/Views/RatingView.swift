// UIKit version: Latest
import UIKit

// Human Tasks:
// 1. Verify that star images are included in the asset catalog
// 2. Test accessibility features with VoiceOver enabled
// 3. Verify color contrast ratios meet WCAG guidelines
// 4. Test rating interactions with different user input methods (touch, assistive touch)

/// A customizable star-based rating view component
/// Requirements addressed: 8.1.1 Design Specifications/Visual Hierarchy
/// Provides a visually appealing and interactive component for displaying and capturing user ratings
class RatingView: UIView {
    
    // MARK: - Constants
    
    private enum Constants {
        static let maxRating = 5
        static let starSize: CGFloat = 24.0
        static let starSpacing: CGFloat = 4.0
        static let animationDuration: TimeInterval = 0.2
    }
    
    // MARK: - Properties
    
    /// Current rating value (0-5)
    private(set) var rating: Int = 0 {
        didSet {
            updateStarAppearance()
        }
    }
    
    /// Collection of star image views
    private var starIcons: [UIImageView] = []
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        // Create star icons
        for _ in 0..<Constants.maxRating {
            let starIcon = UIImageView()
            starIcon.contentMode = .scaleAspectFit
            starIcon.tintColor = .accentColor
            starIcon.image = UIImage(systemName: "star")
            starIcon.setSize(width: Constants.starSize, height: Constants.starSize)
            starIcons.append(starIcon)
            addSubview(starIcon)
        }
        
        // Setup layout
        setupLayout()
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
        
        // Setup accessibility
        setupAccessibility()
        
        Logger.debug("RatingView initialized with \(Constants.maxRating) stars")
    }
    
    private func setupLayout() {
        var previousStar: UIImageView?
        
        for (index, star) in starIcons.enumerated() {
            star.translatesAutoresizingMaskIntoConstraints = false
            
            if let previousStar = previousStar {
                // Anchor to previous star
                star.anchor(
                    left: previousStar.rightAnchor,
                    padding: UIEdgeInsets(top: 0, left: Constants.starSpacing, bottom: 0, right: 0)
                )
            } else {
                // First star anchors to leading edge
                star.anchor(left: leftAnchor)
            }
            
            // Vertical center alignment
            star.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            // If last star, anchor to trailing edge
            if index == starIcons.count - 1 {
                star.anchor(right: rightAnchor)
            }
            
            previousStar = star
        }
    }
    
    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .adjustable
        updateAccessibilityLabel()
    }
    
    // MARK: - Public Methods
    
    /// Sets the current rating value and updates the UI
    /// - Parameter rating: The new rating value (0-5)
    func setRating(_ rating: Int) {
        let validatedRating = min(max(rating, 0), Constants.maxRating)
        
        if self.rating != validatedRating {
            self.rating = validatedRating
            updateAccessibilityLabel()
            Logger.debug("Rating updated to: \(validatedRating)")
        }
    }
    
    // MARK: - Private Methods
    
    private func updateStarAppearance() {
        UIView.animate(withDuration: Constants.animationDuration) {
            for (index, star) in self.starIcons.enumerated() {
                if index < self.rating {
                    star.image = UIImage(systemName: "star.fill")
                } else {
                    star.image = UIImage(systemName: "star")
                }
            }
        }
    }
    
    private func updateAccessibilityLabel() {
        accessibilityLabel = "Rating: \(rating) out of \(Constants.maxRating) stars"
        accessibilityValue = "\(rating)"
    }
    
    // MARK: - User Interaction
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        
        // Calculate rating based on tap location
        let starWidth = Constants.starSize + Constants.starSpacing
        let newRating = Int(min(max(location.x / starWidth + 1, 1), Double(Constants.maxRating)))
        
        setRating(newRating)
        Logger.debug("User tapped rating view. Location: \(location.x), New rating: \(newRating)")
    }
    
    // MARK: - Accessibility
    
    override func accessibilityIncrement() {
        setRating(rating + 1)
    }
    
    override func accessibilityDecrement() {
        setRating(rating - 1)
    }
}