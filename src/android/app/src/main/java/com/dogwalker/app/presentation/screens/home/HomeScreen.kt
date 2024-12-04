// androidx.compose.foundation.lazy version: 1.4.3
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items

// androidx.compose.material version: 1.4.3
import androidx.compose.material.Text
import androidx.compose.material.Button

// androidx.compose.runtime version: 1.4.3
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue

// androidx.compose.foundation version: 1.4.3
import androidx.compose.foundation.layout.*

// Internal imports
import com.dogwalker.app.presentation.screens.home.HomeViewModel
import com.dogwalker.app.presentation.components.BookingCard
import com.dogwalker.app.presentation.components.DogCard
import com.dogwalker.app.presentation.components.WalkCard
import com.dogwalker.app.presentation.theme.Theme

/**
 * Human Tasks:
 * 1. Verify that the navigation setup is properly configured in the app's navigation graph
 * 2. Ensure proper error handling is implemented for loading states and data fetching
 * 3. Test the screen's behavior with different data states (empty, loading, error)
 * 4. Review accessibility features including content descriptions and touch targets
 */

/**
 * HomeScreen composable that serves as the main dashboard for the Dog Walker application.
 * 
 * Requirements addressed:
 * - User Dashboard (1.3 Scope/Core Features/User Management)
 *   Implements a centralized view for users to manage bookings, dogs, and active walks,
 *   providing easy access to key features and information.
 * 
 * - Service Execution (1.3 Scope/Core Features/Service Execution)
 *   Supports live GPS tracking and route recording for active walks by displaying
 *   current walk status and route information.
 *
 * @param viewModel The HomeViewModel instance that manages the screen's state and business logic
 */
@Composable
fun HomeScreen(
    viewModel: HomeViewModel,
    theme: Theme,
    modifier: Modifier = Modifier
) {
    // Collect state from ViewModel
    val bookings by viewModel.bookings.collectAsState()
    val dogs by viewModel.dogs.collectAsState()
    val activeWalkRoute by viewModel.activeWalkRoute.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val error by viewModel.error.collectAsState()

    // Load initial data
    LaunchedEffect(Unit) {
        viewModel.loadBookings()
        viewModel.loadDogs()
    }

    // Main content
    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        // Header section
        Text(
            text = "Welcome Back!",
            style = theme.typography.toMaterialTypography(theme.colorPalette).headlineLarge,
            color = theme.colorPalette.onBackground,
            modifier = Modifier.padding(bottom = 16.dp)
        )

        // Error message if any
        error?.let { errorMessage ->
            Text(
                text = errorMessage,
                style = theme.typography.toMaterialTypography(theme.colorPalette).bodyMedium,
                color = theme.colorPalette.error,
                modifier = Modifier.padding(bottom = 8.dp)
            )
        }

        // Loading indicator
        if (isLoading) {
            CircularProgressIndicator(
                modifier = Modifier.align(Alignment.CenterHorizontally),
                color = theme.colorPalette.primary
            )
        }

        // Main content scrollable list
        LazyColumn(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            // Active Walks Section
            item {
                Text(
                    text = "Active Walks",
                    style = theme.typography.toMaterialTypography(theme.colorPalette).titleLarge,
                    modifier = Modifier.padding(vertical = 8.dp)
                )
            }

            // Display active walk if available
            activeWalkRoute?.let { route ->
                item {
                    WalkCard(
                        walk = route,
                        theme = theme,
                        onCardClick = { walkId ->
                            viewModel.trackActiveWalk(walkId)
                        }
                    )
                }
            }

            // Upcoming Bookings Section
            item {
                Text(
                    text = "Upcoming Bookings",
                    style = theme.typography.toMaterialTypography(theme.colorPalette).titleLarge,
                    modifier = Modifier.padding(vertical = 8.dp)
                )
            }

            // Display bookings
            items(bookings) { booking ->
                BookingCard(
                    booking = booking,
                    theme = theme
                )
            }

            // My Dogs Section
            item {
                Text(
                    text = "My Dogs",
                    style = theme.typography.toMaterialTypography(theme.colorPalette).titleLarge,
                    modifier = Modifier.padding(vertical = 8.dp)
                )
            }

            // Display dogs
            items(dogs) { dog ->
                DogCard(dog = dog)
            }
        }

        // Navigation buttons
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 16.dp),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            Button(
                onClick = { navigateToScreen("bookings") },
                colors = ButtonDefaults.buttonColors(
                    backgroundColor = theme.colorPalette.primary,
                    contentColor = theme.colorPalette.onPrimary
                )
            ) {
                Text("View All Bookings")
            }

            Button(
                onClick = { navigateToScreen("dogs") },
                colors = ButtonDefaults.buttonColors(
                    backgroundColor = theme.colorPalette.primary,
                    contentColor = theme.colorPalette.onPrimary
                )
            ) {
                Text("Manage Dogs")
            }
        }
    }
}

/**
 * Handles navigation between screens in the Dog Walker application.
 *
 * @param destination The screen destination to navigate to
 */
private fun navigateToScreen(destination: String) {
    // Note: Navigation implementation will be handled by the navigation controller
    // This is a placeholder for the actual navigation logic
    println("Navigating to: $destination")
}