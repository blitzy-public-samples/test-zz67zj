// androidx.navigation.compose version: 2.6.0
// androidx.compose.runtime version: 1.5.0
import androidx.compose.runtime.Composable
import androidx.navigation.NavController
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable

// Internal screen imports
import com.dogwalker.app.presentation.screens.auth.LoginScreen
import com.dogwalker.app.presentation.screens.auth.RegisterScreen
import com.dogwalker.app.presentation.screens.home.HomeScreen
import com.dogwalker.app.presentation.screens.booking.BookingScreen
import com.dogwalker.app.presentation.screens.payment.PaymentScreen
import com.dogwalker.app.presentation.screens.walk.ActiveWalkScreen

/**
 * Defines the navigation structure for the Dog Walker application.
 * 
 * Requirement addressed: User Interface Design (8.1.1 Design Specifications)
 * - Ensures consistent navigation between screens and adherence to design specifications
 * - Provides centralized navigation configuration for the application
 */
object Screen {
    // Authentication routes
    const val LOGIN = "login"
    const val REGISTER = "register"

    // Main feature routes
    const val HOME = "home"
    const val BOOKING = "booking"
    const val PAYMENT = "payment"
    const val ACTIVE_WALK = "active_walk"
}

/**
 * Composable function that sets up the navigation graph for the Dog Walker application.
 * 
 * Requirement addressed: User Interface Design (8.1.1 Design Specifications)
 * - Implements navigation structure following Material Design guidelines
 * - Ensures proper screen transitions and state management
 *
 * @param navController The NavController that manages app navigation
 */
@Composable
fun ScreenNavGraph(navController: NavHostController) {
    NavHost(
        navController = navController,
        startDestination = Screen.LOGIN
    ) {
        // Authentication screens
        composable(Screen.LOGIN) {
            LoginScreen()
        }

        composable(Screen.REGISTER) {
            RegisterScreen()
        }

        // Main feature screens
        composable(Screen.HOME) {
            HomeScreen()
        }

        composable(Screen.BOOKING) {
            BookingScreen()
        }

        composable(Screen.PAYMENT) {
            PaymentScreen()
        }

        composable(Screen.ACTIVE_WALK) {
            ActiveWalkScreen()
        }
    }
}