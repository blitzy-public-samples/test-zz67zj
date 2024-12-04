// UIKit version: Latest
import UIKit

// MARK: - Theme Colors Extension
extension UIColor {
    
    // MARK: - Primary Color
    /// The main brand color used for primary actions and key UI elements
    /// Adapts automatically between light and dark modes
    /// Requirements addressed: 8.1.1 Design Specifications/Theming - System-based dark/light mode switching
    static var primaryColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 0.27, green: 0.71, blue: 0.94, alpha: 1.0) // #45B5F0
                default:
                    return UIColor(red: 0.20, green: 0.60, blue: 0.86, alpha: 1.0) // #3399DC
                }
            }
        } else {
            return UIColor(red: 0.20, green: 0.60, blue: 0.86, alpha: 1.0) // #3399DC
        }
    }
    
    // MARK: - Background Color
    /// The main background color used for screens and content areas
    /// Adapts automatically between light and dark modes
    /// Requirements addressed: 8.1.1 Design Specifications/Theming - Consistent color palette across modes
    static var backgroundColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0) // #1C1C1F
                default:
                    return UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0) // #FAFAFA
                }
            }
        } else {
            return UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0) // #FAFAFA
        }
    }
    
    // MARK: - Text Color
    /// The primary text color used throughout the application
    /// Adapts automatically between light and dark modes with appropriate contrast ratios
    /// Requirements addressed: 8.1.1 Design Specifications/Theming - Automatic contrast adjustment
    static var textColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0) // #F7F7F7
                default:
                    return UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0) // #212121
                }
            }
        } else {
            return UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0) // #212121
        }
    }
    
    // MARK: - Accent Color
    /// Secondary brand color used for highlights and accents
    /// Adapts automatically between light and dark modes
    /// Requirements addressed: 8.1.1 Design Specifications/Theming - System-based dark/light mode switching
    static var accentColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 1.00, green: 0.65, blue: 0.31, alpha: 1.0) // #FFA64F
                default:
                    return UIColor(red: 0.95, green: 0.55, blue: 0.20, alpha: 1.0) // #F28C33
                }
            }
        } else {
            return UIColor(red: 0.95, green: 0.55, blue: 0.20, alpha: 1.0) // #F28C33
        }
    }
}