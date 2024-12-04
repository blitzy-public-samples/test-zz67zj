// androidx.navigation.compose version: 2.6.0
import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController

// Internal screen imports
import com.dogwalker.app.presentation.screens.auth.LoginScreen
import com.dogwalker.app.presentation.screens.auth.RegisterScreen
import com.dogwalker.app.presentation.screens.home.HomeScreen
import com.dogwalker.app.presentation.screens.booking.BookingScreen
import com.dogwalker.app.presentation.screens.payment.PaymentScreen
import com.dogwalker.app.presentation.screens.walk.ActiveWalkScreen

/**
 * Human Tasks:
 * 1. Verify that all screen composables are properly implemented and accessible
 * 2. Ensure proper navigation state handling during configuration changes
 * 3. Test deep linking functionality if implemented
 * 4. Review navigation animations and transitions
 */

/**
 * Defines the navigation graph for the Dog Walker Android application.
 * 
 * Requirement addressed: User Interface Design (8.1 User Interface Design/8.1.3 Critical User Flows)
 * Implements the navigation structure between different screens in the application,
 * ensuring seamless user flow between authentication, home, booking, payment, and walk screens.
 */
@Composable
fun NavGraph() {
    // Initialize NavController
    val navController = rememberNavController()

    // Define navigation graph with NavHost
    NavHost(
        navController = navController,
        startDestination = NAV_GRAPH_START_DESTINATION
    ) {
        // Login Screen
        composable(route = "login_screen") {
            LoginScreen()
        }

        // Registration Screen
        composable(route = "register_screen") {
            RegisterScreen()
        }

        // Home Screen
        composable(route = "home_screen") {
            HomeScreen()
        }

        // Booking Screen
        composable(route = "booking_screen") {
            BookingScreen()
        }

        // Payment Screen
        composable(route = "payment_screen") {
            PaymentScreen()
        }

        // Active Walk Screen
        composable(route = "active_walk_screen") {
            ActiveWalkScreen()
        }
    }
}

// Navigation route constants
private const val NAV_GRAPH_START_DESTINATION = "login_screen"