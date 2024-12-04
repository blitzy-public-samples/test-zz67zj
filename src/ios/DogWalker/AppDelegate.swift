// UIKit framework - Latest
import UIKit
// UserNotifications framework - Latest
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Human Tasks
    /*
    1. Configure push notification certificates in Apple Developer Portal
    2. Set up proper error tracking service credentials
    3. Configure proper logging service for production environment
    4. Review and implement proper data retention policies
    */

    // MARK: - Properties
    
    var window: UIWindow?
    private let appRouter = AppRouter()
    
    // MARK: - Application Lifecycle
    
    /// Called when the application has finished launching
    /// Requirement: Application Lifecycle Management (Technical Specification/7.4 Cross-Cutting Concerns/7.4.3 Security Architecture)
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        Logger.info("Application did finish launching")
        
        // Initialize app configuration
        AppConfiguration.shared.initialize()
        
        // Initialize app container and dependencies
        AppContainer.shared.initializeDependencies()
        
        // Set up window and initial view controller
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .backgroundColor
        
        // Configure root view controller
        let loginViewModel = LoginViewModel(
            loginUseCase: LoginUseCase(
                authRepository: AuthRepository(
                    apiClient: APIClient()
                )
            )
        )
        let loginViewController = LoginViewController(viewModel: loginViewModel)
        let navigationController = UINavigationController(rootViewController: loginViewController)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        // Request notification authorization
        requestNotificationAuthorization()
        
        return true
    }
    
    /// Called when the application enters the background
    /// Requirement: Application Lifecycle Management (Technical Specification/7.4 Cross-Cutting Concerns/7.4.3 Security Architecture)
    func applicationDidEnterBackground(_ application: UIApplication) {
        Logger.info("Application did enter background")
        
        // Save any pending changes
        do {
            try CoreDataStack.shared.saveContext()
        } catch {
            Logger.error("Failed to save context: \(error.localizedDescription)")
        }
        
        // Stop location tracking if active
        LocationService().stopTracking()
        
        // Disconnect WebSocket connections
        WebSocketClient().disconnect()
    }
    
    /// Called when the application is about to terminate
    /// Requirement: Application Lifecycle Management (Technical Specification/7.4 Cross-Cutting Concerns/7.4.3 Security Architecture)
    func applicationWillTerminate(_ application: UIApplication) {
        Logger.info("Application will terminate")
        
        // Perform final cleanup
        do {
            try CoreDataStack.shared.saveContext()
        } catch {
            Logger.error("Failed to save context: \(error.localizedDescription)")
        }
        
        // Stop all active services
        LocationService().stopTracking()
        WebSocketClient().disconnect()
    }
    
    // MARK: - Push Notifications
    
    /// Requests authorization for push notifications
    private func requestNotificationAuthorization() {
        let notificationCenter = UNUserNotificationCenter.current()
        
        // Request authorization for alerts, sounds, and badges
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                Logger.info("Notification authorization granted")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                if let error = error {
                    Logger.error("Failed to request notification authorization: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Called when remote notification registration succeeds
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Logger.info("Registered for remote notifications with token: \(tokenString)")
        
        // Store device token for later use
        UserDefaults.standard.set(tokenString, forKey: "APNSToken")
    }
    
    /// Called when remote notification registration fails
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        Logger.error("Failed to register for remote notifications: \(error.localizedDescription)")
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    /// Called when a notification is received while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        Logger.info("Received notification while app in foreground")
        completionHandler([.alert, .sound])
    }
    
    /// Called when user interacts with a notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        Logger.info("User interacted with notification")
        
        // Handle notification based on category identifier
        switch response.notification.request.content.categoryIdentifier {
        case "WALK_UPDATE":
            handleWalkNotification(response.notification)
        case "BOOKING_UPDATE":
            handleBookingNotification(response.notification)
        default:
            break
        }
        
        completionHandler()
    }
    
    // MARK: - Notification Handlers
    
    private func handleWalkNotification(_ notification: UNNotification) {
        guard let walkId = notification.request.content.userInfo["walkId"] as? String else {
            return
        }
        
        // Navigate to walk details
        if let navigationController = window?.rootViewController as? UINavigationController {
            appRouter.navigateToActiveWalk(from: navigationController)
        }
    }
    
    private func handleBookingNotification(_ notification: UNNotification) {
        guard let bookingId = notification.request.content.userInfo["bookingId"] as? String else {
            return
        }
        
        // Navigate to booking details
        if let navigationController = window?.rootViewController as? UINavigationController {
            appRouter.navigateToBooking(from: navigationController)
        }
    }
}