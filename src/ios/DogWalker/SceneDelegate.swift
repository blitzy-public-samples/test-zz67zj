// UIKit framework - Latest
import UIKit

/// SceneDelegate: Manages the lifecycle of the app's scenes and initializes the root view controller
/// Requirements addressed:
/// - Application Lifecycle Management (Technical Specification/7.3 Technical Decisions/7.3.1 Architecture Patterns)
/// - Ensures proper management of app lifecycle events and initialization of the root view controller
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Properties
    
    var window: UIWindow?
    
    // MARK: - Scene Lifecycle Methods
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        Logger.log("Scene will connect to session")
        
        // Initialize global configurations
        AppConfiguration.shared.initialize()
        
        // Initialize application dependencies
        AppContainer.shared.initializeDependencies()
        
        guard let windowScene = (scene as? UIWindowScene) else {
            Logger.error("Failed to cast scene to UIWindowScene")
            return
        }
        
        // Create and configure the window
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // Create navigation controller and set root view controller
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        
        // Navigate to home screen using AppRouter
        AppRouter().navigateToHome(from: navigationController)
        
        // Make window visible
        window.makeKeyAndVisible()
        
        Logger.log("Scene setup completed successfully")
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        Logger.log("Scene did disconnect")
        // Release any resources associated with this scene
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        Logger.log("Scene did become active")
        // Resume any tasks that were paused when the scene was inactive
    }

    func sceneWillResignActive(_ scene: UIScene) {
        Logger.log("Scene will resign active")
        // Pause any tasks that should not run while the scene is inactive
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        Logger.log("Scene will enter foreground")
        // Prepare the UI for display
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        Logger.log("Scene did enter background")
        // Save application state and release shared resources
    }
}