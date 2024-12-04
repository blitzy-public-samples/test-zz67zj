// UIKit - Latest version
import UIKit

// MARK: - Human Tasks
/*
Prerequisites:
1. Ensure proper Auto Layout constraints are maintained when testing on different device sizes
2. Verify accessibility labels and traits are properly configured for VoiceOver support
3. Test color contrast ratios in both light and dark modes for text readability
*/

/// A custom UITableViewCell subclass for displaying information about a dog walking session
/// Requirements addressed:
/// - Service Execution (1.3 Scope/Core Features/Service Execution)
/// - Theming (8.1 User Interface Design/8.1.1 Design Specifications/Theming)
/// - Date and Time Formatting (Technical Specification/8.3 API Design/8.3.2 API Specifications)
class WalkCell: UITableViewCell {
    
    // MARK: - UI Components
    
    private let walkerNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dogNamesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusIndicator: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // Add subviews
        contentView.addSubview(statusIndicator)
        contentView.addSubview(walkerNameLabel)
        contentView.addSubview(dogNamesLabel)
        contentView.addSubview(timeLabel)
        
        // Configure cell appearance
        backgroundColor = .systemBackground
        selectionStyle = .none
        
        // Set up Auto Layout constraints
        NSLayoutConstraint.activate([
            // Status indicator constraints
            statusIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusIndicator.widthAnchor.constraint(equalToConstant: 12),
            statusIndicator.heightAnchor.constraint(equalToConstant: 12),
            
            // Walker name label constraints
            walkerNameLabel.leadingAnchor.constraint(equalTo: statusIndicator.trailingAnchor, constant: 12),
            walkerNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            walkerNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Dog names label constraints
            dogNamesLabel.leadingAnchor.constraint(equalTo: walkerNameLabel.leadingAnchor),
            dogNamesLabel.topAnchor.constraint(equalTo: walkerNameLabel.bottomAnchor, constant: 4),
            dogNamesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Time label constraints
            timeLabel.leadingAnchor.constraint(equalTo: walkerNameLabel.leadingAnchor),
            timeLabel.topAnchor.constraint(equalTo: dogNamesLabel.bottomAnchor, constant: 4),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configuration
    
    /// Configures the cell with walk data
    /// - Parameter walk: The walk instance containing the data to display
    func configure(with walk: Walk) {
        // Set walker name
        walkerNameLabel.text = walk.walker.name
        walkerNameLabel.textColor = .textColor
        
        // Set dog names
        let dogNames = walk.dogs.map { $0.name }.joined(separator: ", ")
        dogNamesLabel.text = dogNames
        
        // Format and set time
        let startTimeString = DateFormatter.stringFromDate(walk.startTime)
        let endTimeString = DateFormatter.stringFromDate(walk.endTime)
        timeLabel.text = "\(startTimeString) - \(endTimeString)"
        
        // Set status indicator color based on walk status
        switch walk.status {
        case "scheduled":
            statusIndicator.backgroundColor = .systemYellow
        case "started", "in_progress":
            statusIndicator.backgroundColor = .primaryColor
        case "completed":
            statusIndicator.backgroundColor = .systemGreen
        case "cancelled":
            statusIndicator.backgroundColor = .systemRed
        default:
            statusIndicator.backgroundColor = .systemGray
        }
        
        // Configure accessibility
        configureAccessibility(walk: walk, dogNames: dogNames)
    }
    
    // MARK: - Accessibility
    
    private func configureAccessibility(walk: Walk, dogNames: String) {
        let statusDescription: String
        switch walk.status {
        case "scheduled":
            statusDescription = "Scheduled"
        case "started":
            statusDescription = "Started"
        case "in_progress":
            statusDescription = "In Progress"
        case "completed":
            statusDescription = "Completed"
        case "cancelled":
            statusDescription = "Cancelled"
        default:
            statusDescription = walk.status
        }
        
        let startTimeString = DateFormatter.stringFromDate(walk.startTime)
        let endTimeString = DateFormatter.stringFromDate(walk.endTime)
        
        accessibilityLabel = "Walk with \(walk.walker.name). Dogs: \(dogNames). Time: \(startTimeString) to \(endTimeString). Status: \(statusDescription)"
        accessibilityTraits = .button
        isAccessibilityElement = true
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        walkerNameLabel.text = nil
        dogNamesLabel.text = nil
        timeLabel.text = nil
        statusIndicator.backgroundColor = nil
    }
}