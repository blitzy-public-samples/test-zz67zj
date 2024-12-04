// UserNotifications framework - Latest
import UserNotifications
// Internal imports using relative paths
import "../../Utilities/Logger"
import "../../Data/Network/APIClient"
import "../../Data/Repositories/UserRepository"
import "../../Presentation/Common/Extensions/UIViewController+Alert"

/// NotificationService: Handles notification-related functionalities for the Dog Walker iOS application
/// Requirement: Push Notifications (1.3 Scope/Core Features/Service Execution)
/// Supports sending and managing push notifications to keep users informed about booking updates, walk statuses, and other events
class NotificationService {
    
    // MARK: - Human Tasks
    /*
    1. Configure push notification capabilities in Xcode project settings
    2. Set up Apple Push Notification Service (APNS) certificates
    3. Configure notification categories and actions in the app delegate
    4. Verify proper notification permission handling
    */
    
    // MARK: - Properties
    
    private let apiClient: APIClient
    private let userRepository: UserRepository
    private let notificationCenter: UNUserNotificationCenter
    
    // MARK: - Initialization
    
    /// Initializes the NotificationService with required dependencies
    /// - Parameters:
    ///   - apiClient: The API client for network requests
    ///   - userRepository: The repository for user data
    ///   - notificationCenter: The notification center instance (defaults to current)
    init(
        apiClient: APIClient,
        userRepository: UserRepository,
        notificationCenter: UNUserNotificationCenter = .current()
    ) {
        self.apiClient = apiClient
        self.userRepository = userRepository
        self.notificationCenter = notificationCenter
    }
    
    // MARK: - Public Methods
    
    /// Sends a push notification to a specific user
    /// - Parameters:
    ///   - userId: The ID of the user to send the notification to
    ///   - message: The notification message content
    public func sendPushNotification(userId: String, message: String) {
        Task {
            do {
                // Fetch user's notification preferences
                guard let user = try await userRepository.fetchUserById(userId) else {
                    Logger.error("Failed to fetch user with ID: \(userId)")
                    return
                }
                
                // Log notification attempt
                Logger.info("Attempting to send push notification to user: \(userId)")
                
                // Construct notification payload
                let payload: [String: Any] = [
                    "user_id": userId,
                    "message": message,
                    "timestamp": DateFormatter.stringFromDate(Date())
                ]
                
                // Send notification through API
                apiClient.performRequest(
                    endpoint: "/api/v1/notifications",
                    parameters: payload
                ) { result in
                    switch result {
                    case .success(_):
                        Logger.info("Successfully sent push notification to user: \(userId)")
                    case .failure(let error):
                        self.handleNotificationError(error)
                    }
                }
            } catch {
                handleNotificationError(error)
            }
        }
    }
    
    /// Schedules a local notification to be delivered at a specific time
    /// - Parameters:
    ///   - title: The notification title
    ///   - message: The notification message
    ///   - deliveryDate: The date when the notification should be delivered
    public func scheduleLocalNotification(
        title: String,
        message: String,
        deliveryDate: Date
    ) {
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default
        
        // Create calendar trigger
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: deliveryDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create request with unique identifier
        let identifier = UUID().uuidString
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        notificationCenter.add(request) { error in
            if let error = error {
                self.handleNotificationError(error)
            } else {
                Logger.info("Successfully scheduled local notification for: \(deliveryDate)")
            }
        }
    }
    
    /// Handles errors related to notification delivery or scheduling
    /// - Parameter error: The error to handle
    public func handleNotificationError(_ error: Error) {
        // Log the error
        Logger.error("Notification error: \(error.localizedDescription)")
        
        // Present alert to user on main thread
        DispatchQueue.main.async {
            if let topViewController = UIApplication.shared.keyWindow?.rootViewController {
                topViewController.presentAlert(
                    title: "Notification Error",
                    message: "Failed to process notification: \(error.localizedDescription)"
                )
            }
        }
    }
}

// MARK: - Private Extensions

private extension NotificationService {
    /// Validates notification content
    /// - Parameters:
    ///   - title: The notification title
    ///   - message: The notification message
    /// - Returns: Boolean indicating if content is valid
    func validateNotificationContent(title: String, message: String) -> Bool {
        guard !title.isEmpty, !message.isEmpty else {
            Logger.warning("Invalid notification content: Empty title or message")
            return false
        }
        
        // Check content length limits
        let titleLimit = 50
        let messageLimit = 200
        
        guard title.count <= titleLimit, message.count <= messageLimit else {
            Logger.warning("Notification content exceeds length limits")
            return false
        }
        
        return true
    }
}