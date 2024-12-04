// UIKit framework - Latest
import UIKit

/// AppRouter: Manages navigation between different screens in the DogWalker iOS application
/// Requirements addressed:
/// - User Interface Navigation (8.1 User Interface Design/8.1.3 Critical User Flows)
/// - Ensures seamless navigation between screens such as Login, Registration, Home, Booking, and Active Walk
class AppRouter {
    
    // MARK: - Properties
    
    /// Base API URL for constructing navigation-related URLs
    private let baseApiUrl: String
    
    // MARK: - Initialization
    
    /// Initializes the AppRouter with default configurations
    init() {
        self.baseApiUrl = Constants.BASE_API_URL
        Logger.info("AppRouter initialized with base URL: \(baseApiUrl)")
    }
    
    // MARK: - Navigation Methods
    
    /// Navigates to the Login screen
    /// - Parameter currentViewController: The view controller initiating the navigation
    func navigateToLogin(from currentViewController: UIViewController) {
        Logger.info("Navigating to Login screen")
        
        // Create login view model and view controller
        let loginViewModel = LoginViewModel(
            loginUseCase: LoginUseCase(
                authRepository: AuthRepository(
                    apiClient: APIClient()
                )
            )
        )
        let loginViewController = LoginViewController(viewModel: loginViewModel)
        
        // Push the login view controller
        currentViewController.navigationController?.pushViewController(
            loginViewController,
            animated: true
        )
    }
    
    /// Navigates to the Registration screen
    /// - Parameter currentViewController: The view controller initiating the navigation
    func navigateToRegister(from currentViewController: UIViewController) {
        Logger.info("Navigating to Register screen")
        
        // Create register view model and view controller
        let registerViewModel = RegisterViewModel(
            registerUseCase: RegisterUseCase(
                authRepository: AuthRepository(
                    apiClient: APIClient()
                )
            )
        )
        let registerViewController = RegisterViewController(viewModel: registerViewModel)
        
        // Push the register view controller
        currentViewController.navigationController?.pushViewController(
            registerViewController,
            animated: true
        )
    }
    
    /// Navigates to the Home screen
    /// - Parameter currentViewController: The view controller initiating the navigation
    func navigateToHome(from currentViewController: UIViewController) {
        Logger.info("Navigating to Home screen")
        
        // Create home view model and view controller
        let homeViewModel = HomeViewModel(
            loginUseCase: LoginUseCase(
                authRepository: AuthRepository(
                    apiClient: APIClient()
                )
            ),
            getBookingsUseCase: GetBookingsUseCase(
                bookingRepository: BookingRepository(
                    apiClient: APIClient()
                )
            )
        )
        let homeViewController = HomeViewController(viewModel: homeViewModel)
        
        // Set the home view controller as the root
        currentViewController.navigationController?.setViewControllers(
            [homeViewController],
            animated: true
        )
    }
    
    /// Navigates to the Booking screen
    /// - Parameter currentViewController: The view controller initiating the navigation
    func navigateToBooking(from currentViewController: UIViewController) {
        Logger.info("Navigating to Booking screen")
        
        // Create booking view model and view controller
        let bookingViewModel = BookingViewModel(
            getBookingsUseCase: GetBookingsUseCase(
                bookingRepository: BookingRepository(
                    apiClient: APIClient()
                )
            )
        )
        let bookingViewController = BookingViewController(viewModel: bookingViewModel)
        
        // Push the booking view controller
        currentViewController.navigationController?.pushViewController(
            bookingViewController,
            animated: true
        )
    }
    
    /// Navigates to the Active Walk screen
    /// - Parameter currentViewController: The view controller initiating the navigation
    func navigateToActiveWalk(from currentViewController: UIViewController) {
        Logger.info("Navigating to Active Walk screen")
        
        // Create active walk view controller
        let activeWalkViewController = ActiveWalkViewController()
        
        // Push the active walk view controller
        currentViewController.navigationController?.pushViewController(
            activeWalkViewController,
            animated: true
        )
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension AppRouter {
    /// Tests navigation flow between screens
    func testNavigationFlow(from currentViewController: UIViewController) {
        Logger.debug("Testing navigation flow")
        
        // Simulate navigation sequence
        navigateToLogin(from: currentViewController)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.navigateToRegister(from: currentViewController)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigateToHome(from: currentViewController)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.navigateToBooking(from: currentViewController)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.navigateToActiveWalk(from: currentViewController)
                    }
                }
            }
        }
    }
}
#endif