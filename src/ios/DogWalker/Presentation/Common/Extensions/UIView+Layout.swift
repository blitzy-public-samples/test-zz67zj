// UIKit version: Latest
import UIKit
import Foundation

// Human Tasks:
// 1. Verify that Auto Layout constraints are working correctly across all supported iOS versions
// 2. Test layout behavior with dynamic text sizes and different device orientations
// 3. Ensure RTL language support is properly handled by the layout constraints

/// Extension providing utility methods for UIView layout management
/// Requirements addressed: 8.1.1 Design Specifications/Responsive Design
/// Provides flexible layouts with constraint-based design to support various screen sizes and orientations
extension UIView {
    
    // MARK: - Layout Methods
    
    /// Adds layout constraints to the view using a visual format string
    /// - Parameters:
    ///   - format: Visual format string defining the constraints
    ///   - views: Dictionary of views referenced in the format string
    /// - Returns: Array of created NSLayoutConstraints
    @discardableResult
    func addConstraintsWithFormat(_ format: String, views: [String: Any]) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        
        let constraints: [NSLayoutConstraint]
        do {
            constraints = try NSLayoutConstraint.constraints(
                withVisualFormat: format,
                options: [],
                metrics: nil,
                views: views
            )
            addConstraints(constraints)
            Logger.debug("Added constraints with format: \(format)")
        } catch {
            Logger.error("Failed to create constraints with format: \(format), error: \(error)")
            return []
        }
        
        return constraints
    }
    
    /// Centers the view within its superview
    /// - Note: The view must have a superview for this method to work
    func centerInSuperview() {
        guard let superview = superview else {
            Logger.warning("Cannot center view - no superview found")
            return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let centerX = centerXAnchor.constraint(equalTo: superview.centerXAnchor)
        let centerY = centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        
        NSLayoutConstraint.activate([centerX, centerY])
        Logger.debug("Centered view in superview")
    }
    
    /// Anchors the view to specified edges of its superview with padding
    /// - Parameters:
    ///   - top: Top anchor constraint (optional)
    ///   - left: Left anchor constraint (optional)
    ///   - bottom: Bottom anchor constraint (optional)
    ///   - right: Right anchor constraint (optional)
    ///   - padding: Edge insets defining the padding from the superview edges
    func anchor(
        top: NSLayoutYAxisAnchor? = nil,
        left: NSLayoutXAxisAnchor? = nil,
        bottom: NSLayoutYAxisAnchor? = nil,
        right: NSLayoutXAxisAnchor? = nil,
        padding: UIEdgeInsets = .zero
    ) {
        translatesAutoresizingMaskIntoConstraints = false
        
        var constraints: [NSLayoutConstraint] = []
        
        if let top = top {
            constraints.append(topAnchor.constraint(equalTo: top, constant: padding.top))
        }
        
        if let left = left {
            constraints.append(leftAnchor.constraint(equalTo: left, constant: padding.left))
        }
        
        if let bottom = bottom {
            constraints.append(bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom))
        }
        
        if let right = right {
            constraints.append(rightAnchor.constraint(equalTo: right, constant: -padding.right))
        }
        
        NSLayoutConstraint.activate(constraints)
        Logger.debug("Anchored view with padding: \(padding)")
    }
    
    /// Anchors the view to all edges of its superview with equal padding
    /// - Parameter padding: The padding to apply to all edges
    func anchorToSuperview(padding: CGFloat = 0) {
        guard let superview = superview else {
            Logger.warning("Cannot anchor view - no superview found")
            return
        }
        
        anchor(
            top: superview.topAnchor,
            left: superview.leftAnchor,
            bottom: superview.bottomAnchor,
            right: superview.rightAnchor,
            padding: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        )
    }
    
    /// Sets the size constraints for the view
    /// - Parameters:
    ///   - width: Desired width (optional)
    ///   - height: Desired height (optional)
    func setSize(width: CGFloat? = nil, height: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        
        var constraints: [NSLayoutConstraint] = []
        
        if let width = width {
            constraints.append(widthAnchor.constraint(equalToConstant: width))
        }
        
        if let height = height {
            constraints.append(heightAnchor.constraint(equalToConstant: height))
        }
        
        NSLayoutConstraint.activate(constraints)
        Logger.debug("Set size constraints - width: \(String(describing: width)), height: \(String(describing: height))")
    }
    
    /// Sets equal width and height constraints (square aspect ratio)
    /// - Parameter size: The size for both width and height
    func setSquareSize(_ size: CGFloat) {
        setSize(width: size, height: size)
    }
    
    /// Sets the view's size to match its superview
    func matchSuperviewSize() {
        guard let superview = superview else {
            Logger.warning("Cannot match superview size - no superview found")
            return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            widthAnchor.constraint(equalTo: superview.widthAnchor),
            heightAnchor.constraint(equalTo: superview.heightAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        Logger.debug("Matched superview size")
    }
}