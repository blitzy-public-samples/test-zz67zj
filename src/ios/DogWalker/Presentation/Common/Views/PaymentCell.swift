// UIKit - Latest version
import UIKit

// MARK: - Human Tasks
/*
Prerequisites:
1. Ensure proper currency formatting is configured for the target market regions
2. Verify accessibility labels and traits are appropriate for VoiceOver support
3. Test color contrast ratios in both light and dark modes
*/

/// A UITableViewCell subclass for displaying payment details
/// Requirements addressed:
/// - Payments (1.3 Scope/Core Features/Payments): Supports payment information display
/// - Theming (8.1.1 Design Specifications/Theming): System-based dark/light mode switching
/// - Date Formatting (8.3.2 API Specifications): Consistent date formatting
final class PaymentCell: UITableViewCell {
    
    // MARK: - UI Components
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityTraits = .staticText
        return label
    }()
    
    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityTraits = .staticText
        return label
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityTraits = .staticText
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityTraits = .staticText
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let horizontalStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
        setupAccessibility()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    /// Configures the cell with payment information
    /// - Parameter payment: The Payment object containing the information to display
    func configure(with payment: Payment) {
        // Format amount with 2 decimal places
        amountLabel.text = String(format: "%.2f", payment.amount)
        currencyLabel.text = payment.currency
        
        // Format timestamp using consistent date formatter
        timestampLabel.text = DateFormatter.stringFromDate(payment.timestamp)
        
        statusLabel.text = payment.status
        
        // Apply theme colors
        applyThemeColors()
        
        // Update accessibility label
        updateAccessibilityLabel(for: payment)
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        contentView.addSubview(stackView)
        
        horizontalStackView.addArrangedSubview(amountLabel)
        horizontalStackView.addArrangedSubview(currencyLabel)
        
        stackView.addArrangedSubview(horizontalStackView)
        stackView.addArrangedSubview(timestampLabel)
        stackView.addArrangedSubview(statusLabel)
        
        selectionStyle = .none
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .button
    }
    
    private func applyThemeColors() {
        // Apply theme-specific colors
        amountLabel.textColor = .textColor
        currencyLabel.textColor = .textColor.withAlphaComponent(0.8)
        timestampLabel.textColor = .textColor.withAlphaComponent(0.6)
        statusLabel.textColor = .primaryColor
        
        backgroundColor = .backgroundColor
    }
    
    private func updateAccessibilityLabel(for payment: Payment) {
        let amountString = String(format: "%.2f %@", payment.amount, payment.currency)
        let dateString = DateFormatter.stringFromDate(payment.timestamp)
        accessibilityLabel = "Payment of \(amountString) on \(dateString). Status: \(payment.status)"
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        amountLabel.text = nil
        currencyLabel.text = nil
        timestampLabel.text = nil
        statusLabel.text = nil
    }
}