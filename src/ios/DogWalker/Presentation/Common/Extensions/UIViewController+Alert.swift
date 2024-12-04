// UIKit version: Latest
import UIKit

// Human Tasks:
// 1. Verify that the alert presentation style matches the app's design guidelines
// 2. Ensure alert text contrast meets accessibility standards
// 3. Test alerts with VoiceOver enabled to verify accessibility

/// Extension providing reusable alert presentation functionality for view controllers
/// Requirements addressed: 8.1.1 Design Specifications/Accessibility
/// Ensures consistent alert presentation and accessibility across the application
extension UIViewController {
    
    /// Presents an alert with a title, message, and optional actions
    /// - Parameters:
    ///   - title: The title text to display in the alert
    ///   - message: The message text to display in the alert
    ///   - actions: Optional array of UIAlertActions to add to the alert
    public func presentAlert(
        title: String,
        message: String,
        actions: [UIAlertAction]? = nil
    ) {
        // Create alert controller on the main thread to ensure UI updates are thread-safe
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Create alert controller with provided title and message
            let alertController = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            
            // Configure alert appearance using theme colors
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.textColor
            ]
            let messageAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.textColor
            ]
            
            // Set attributed strings for title and message with themed colors
            let attributedTitle = NSAttributedString(
                string: title,
                attributes: titleAttributes
            )
            let attributedMessage = NSAttributedString(
                string: message,
                attributes: messageAttributes
            )
            
            alertController.setValue(attributedTitle, forKey: "attributedTitle")
            alertController.setValue(attributedMessage, forKey: "attributedMessage")
            
            // If no actions are provided, add a default "OK" action
            if let actions = actions, !actions.isEmpty {
                actions.forEach { alertController.addAction($0) }
            } else {
                let okAction = UIAlertAction(
                    title: "OK",
                    style: .default,
                    handler: nil
                )
                alertController.addAction(okAction)
            }
            
            // Log alert presentation for debugging and monitoring
            Logger.log(
                "Presenting alert - Title: \(title), Message: \(message)",
                level: .info
            )
            
            // Present the alert controller
            self.present(
                alertController,
                animated: true,
                completion: nil
            )
        }
    }
}

// MARK: - Convenience Methods

extension UIViewController {
    /// Presents a simple alert with just an OK button
    /// - Parameters:
    ///   - title: The title text to display in the alert
    ///   - message: The message text to display in the alert
    public func presentSimpleAlert(
        title: String,
        message: String
    ) {
        presentAlert(
            title: title,
            message: message,
            actions: nil
        )
    }
    
    /// Presents a confirmation alert with OK and Cancel buttons
    /// - Parameters:
    ///   - title: The title text to display in the alert
    ///   - message: The message text to display in the alert
    ///   - okHandler: Handler to be called when OK is tapped
    public func presentConfirmationAlert(
        title: String,
        message: String,
        okHandler: ((UIAlertAction) -> Void)?
    ) {
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        )
        
        let okAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: okHandler
        )
        
        presentAlert(
            title: title,
            message: message,
            actions: [cancelAction, okAction]
        )
    }
}