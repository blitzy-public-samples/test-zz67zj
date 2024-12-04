// androidx.compose.foundation.lazy version: 1.5.0
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items

// androidx.compose.material version: 1.5.0
import androidx.compose.material.Text
import androidx.compose.material.Button
import androidx.compose.material.CircularProgressIndicator

// androidx.compose.runtime version: 1.5.0
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember

// androidx.compose.foundation version: 1.5.0
import androidx.compose.foundation.layout.*

// Navigation
import androidx.navigation.NavController

// Internal imports
import com.dogwalker.app.presentation.screens.home.HomeViewModel
import com.dogwalker.app.presentation.components.BookingCard
import com.dogwalker.app.presentation.components.DogCard
import com.dogwalker.app.presentation.theme.Theme

/**
 * Human Tasks:
 * 1. Verify that the navigation setup is properly configured in the app's navigation graph
 * 2. Ensure proper error handling is implemented for loading states and data fetching
 * 3. Test the screen's behavior with different data states (empty, loading, error)
 * 4. Review accessibility features including content descriptions and touch targets
 */

/**
 * HomeScreen composable that serves as the main dashboard for users in the Dog Walker application.
 * 
 * Requirements addressed:
 * - User Dashboard (1.3 Scope/Core Features/User Management)
 *   Implements a centralized view for users to manage bookings, dogs, and active walks.
 * 
 * - Service Execution (1.3 Scope/Core Features/Service Execution)
 *   Supports live GPS tracking and route recording for active walks.
 *
 * @param navController Navigation controller for handling screen navigation
 * @param viewModel ViewModel that manages the screen's state and business logic
 */
@Composable
fun HomeScreen(
    navController: NavController,
    viewModel: HomeViewModel
) {
    // Access theme components
    val colorPalette = Theme.LocalColorPalette.current
    val typography = Theme.LocalTypography.current

    // Load initial data
    LaunchedEffect(Unit) {
        viewModel.loadBookings()
        viewModel.loadDogs()
    }

    // Main content
    Column(
        modifier = androidx.compose.ui.Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        // Header section
        Text(
            text = "Welcome Back!",
            style = typography.toMaterialTypography(colorPalette).headlineLarge,
            color = colorPalette.onBackground,
            modifier = androidx.compose.ui.Modifier.padding(bottom = 16.dp)
        )

        // Error message if any
        viewModel.error.value?.let { errorMessage ->
            Text(
                text = errorMessage,
                style = typography.toMaterialTypography(colorPalette).bodyMedium,
                color = colorPalette.error,
                modifier = androidx.compose.ui.Modifier.padding(bottom = 8.dp)
            )
        }

        // Loading indicator
        if (viewModel.isLoading.value) {
            CircularProgressIndicator(
                modifier = androidx.compose.ui.Modifier.align(androidx.compose.ui.Alignment.CenterHorizontally),
                color = colorPalette.primary
            )
        }

        // Main content scrollable list
        LazyColumn(
            modifier = androidx.compose.ui.Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            // Active Walks Section
            item {
                Text(
                    text = "Active Walks",
                    style = typography.toMaterialTypography(colorPalette).titleLarge,
                    modifier = androidx.compose.ui.Modifier.padding(vertical = 8.dp)
                )
            }

            // Display active walk if available
            viewModel.activeWalkRoute.value?.let { route ->
                item {
                    Button(
                        onClick = { navController.navigate("active_walk_screen") },
                        modifier = androidx.compose.ui.Modifier.fillMaxWidth()
                    ) {
                        Text("View Active Walk")
                    }
                }
            }

            // Upcoming Bookings Section
            item {
                Text(
                    text = "Upcoming Bookings",
                    style = typography.toMaterialTypography(colorPalette).titleLarge,
                    modifier = androidx.compose.ui.Modifier.padding(vertical = 8.dp)
                )
            }

            // Display bookings
            items(viewModel.bookings.value ?: emptyList()) { booking ->
                BookingCard(
                    booking = booking,
                    theme = Theme(colorPalette, Theme.LocalShapeTheme.current, typography)
                )
            }

            // My Dogs Section
            item {
                Text(
                    text = "My Dogs",
                    style = typography.toMaterialTypography(colorPalette).titleLarge,
                    modifier = androidx.compose.ui.Modifier.padding(vertical = 8.dp)
                )
            }

            // Display dogs
            items(viewModel.dogs.value ?: emptyList()) { dog ->
                DogCard(dog = dog)
            }
        }

        // Navigation buttons
        Row(
            modifier = androidx.compose.ui.Modifier
                .fillMaxWidth()
                .padding(vertical = 16.dp),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            Button(
                onClick = { navController.navigate("bookings") },
                colors = androidx.compose.material.ButtonDefaults.buttonColors(
                    backgroundColor = colorPalette.primary,
                    contentColor = colorPalette.onPrimary
                )
            ) {
                Text("View All Bookings")
            }

            Button(
                onClick = { navController.navigate("dogs") },
                colors = androidx.compose.material.ButtonDefaults.buttonColors(
                    backgroundColor = colorPalette.primary,
                    contentColor = colorPalette.onPrimary
                )
            ) {
                Text("Manage Dogs")
            }
        }
    }
}