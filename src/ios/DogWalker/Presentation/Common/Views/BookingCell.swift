// UIKit version: Latest
import UIKit

// MARK: - Human Tasks
/*
Prerequisites:
1. Ensure proper Auto Layout constraints are maintained when testing on different device sizes
2. Verify text truncation and multiline behavior works correctly with long content
3. Test color contrast ratios meet accessibility standards in both light and dark modes
*/

/// A UITableViewCell subclass for displaying booking details
/// Requirements addressed:
/// - Booking System (1.3 Scope/Core Features/Booking System)
/// - Theming (8.1 User Interface Design/8.1.1 Design Specifications/Theming)
/// - Date and Time Formatting (Technical Specification/8.3 API Design/8.3.2 API Specifications)
class BookingCell: UITableViewCell {
    
    // MARK: - UI Components
    
    private let ownerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dogNamesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scheduledTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // Add subviews
        contentView.addSubview(ownerLabel)
        contentView.addSubview(dogNamesLabel)
        contentView.addSubview(scheduledTimeLabel)
        
        // Configure colors
        applyThemeColors()
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Owner label constraints
            ownerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            ownerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            ownerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Dog names label constraints
            dogNamesLabel.topAnchor.constraint(equalTo: ownerLabel.bottomAnchor, constant: 4),
            dogNamesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dogNamesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Scheduled time label constraints
            scheduledTimeLabel.topAnchor.constraint(equalTo: dogNamesLabel.bottomAnchor, constant: 4),
            scheduledTimeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            scheduledTimeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            scheduledTimeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    private func applyThemeColors() {
        backgroundColor = .backgroundColor
        ownerLabel.textColor = .textColor
        dogNamesLabel.textColor = .textColor
        scheduledTimeLabel.textColor = .primaryColor
    }
    
    // MARK: - Configuration
    
    /// Configures the cell with booking data
    /// - Parameter booking: The booking object containing the data to display
    func configure(with booking: Booking) {
        // Set owner name
        ownerLabel.text = booking.owner.name
        
        // Set dog names (comma-separated list)
        let dogNames = booking.dogs.map { $0.name }.joined(separator: ", ")
        dogNamesLabel.text = dogNames
        
        // Format and set scheduled time
        scheduledTimeLabel.text = DateFormatter.stringFromDate(booking.scheduledAt)
        
        // Ensure theme colors are applied
        applyThemeColors()
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ownerLabel.text = nil
        dogNamesLabel.text = nil
        scheduledTimeLabel.text = nil
    }
    
    // MARK: - Theme Updates
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            applyThemeColors()
        }
    }
}