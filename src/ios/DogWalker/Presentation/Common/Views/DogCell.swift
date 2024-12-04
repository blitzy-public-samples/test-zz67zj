// UIKit version: Latest
import UIKit

// MARK: - Human Tasks
/*
Prerequisites:
1. Test cell layout with different font sizes and accessibility settings
2. Verify proper cell reuse behavior in table views
3. Test layout behavior with RTL languages
*/

/// A UITableViewCell subclass for displaying dog-related information
/// Requirements addressed: 8.1.1 Design Specifications/Responsive Design
/// Provides a reusable and responsive UI component for displaying dog details in lists
class DogCell: UITableViewCell {
    
    // MARK: - UI Components
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let breedLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .textColor
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
        contentView.addSubview(nameLabel)
        contentView.addSubview(breedLabel)
        contentView.addSubview(ageLabel)
        
        // Configure cell appearance
        backgroundColor = .backgroundColor
        selectionStyle = .none
        
        // Setup layout constraints
        nameLabel.anchor(
            top: contentView.topAnchor,
            left: contentView.leftAnchor,
            right: contentView.rightAnchor,
            padding: UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
        )
        
        breedLabel.anchor(
            top: nameLabel.bottomAnchor,
            left: contentView.leftAnchor,
            right: contentView.rightAnchor,
            padding: UIEdgeInsets(top: 4, left: 16, bottom: 0, right: 16)
        )
        
        ageLabel.anchor(
            top: breedLabel.bottomAnchor,
            left: contentView.leftAnchor,
            bottom: contentView.bottomAnchor,
            right: contentView.rightAnchor,
            padding: UIEdgeInsets(top: 4, left: 16, bottom: 12, right: 16)
        )
    }
    
    // MARK: - Configuration
    
    /// Configures the cell with dog information
    /// - Parameter dog: The Dog instance containing the information to display
    func configure(with dog: Dog) {
        nameLabel.text = dog.name
        breedLabel.text = dog.breed
        ageLabel.text = "\(dog.age) year\(dog.age == 1 ? "" : "s") old"
        
        // Apply theme colors
        nameLabel.textColor = .textColor
        breedLabel.textColor = .textColor
        ageLabel.textColor = .textColor
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset labels to default state
        nameLabel.text = nil
        breedLabel.text = nil
        ageLabel.text = nil
    }
}