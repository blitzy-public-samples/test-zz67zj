// androidx.compose.runtime version: 1.5.0
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue

// androidx.compose.foundation.layout version: 1.5.0
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items

// androidx.compose.material version: 1.5.0
import androidx.compose.material.CircularProgressIndicator
import androidx.compose.material.Divider
import androidx.compose.material.Icon
import androidx.compose.material.IconButton
import androidx.compose.material.MaterialTheme
import androidx.compose.material.Text
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.ExitToApp

// Internal imports
import com.dogwalker.app.presentation.screens.profile.ProfileViewModel
import com.dogwalker.app.presentation.theme.Theme
import com.dogwalker.app.presentation.components.LoadingButton
import com.dogwalker.app.presentation.components.RatingBar
import com.dogwalker.app.presentation.navigation.NavGraph

/**
 * Human Tasks:
 * 1. Verify proper error handling UI for profile data loading failures
 * 2. Test profile screen layout on different screen sizes and orientations
 * 3. Ensure accessibility features work correctly with TalkBack
 * 4. Review loading states and progress indicators for user feedback
 */

/**
 * ProfileScreen composable that displays user profile information, associated dogs,
 * and booking history.
 *
 * Requirements addressed:
 * - User Management (1.3 Scope/Core Features/User Management)
 *   Provides interface for viewing and managing user profile details
 * - Dog Profile Management (1.3 Scope/Core Features/User Management)
 *   Displays list of dogs associated with the user
 * - Booking Management (1.3 Scope/Core Features/Booking System)
 *   Shows user's booking history and upcoming bookings
 *
 * @param viewModel ViewModel instance that manages profile data and operations
 */
@Composable
fun ProfileScreen(viewModel: ProfileViewModel) {
    // State management
    var isLoading by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf<String?>(null) }

    // Theme components
    val colorPalette = Theme.LocalColorPalette.current
    val typography = Theme.LocalTypography.current
    val shapeTheme = Theme.LocalShapeTheme.current

    // Initialize loading button
    val logoutButton = remember {
        LoadingButton(
            buttonText = "Logout",
            isLoading = false
        )
    }

    // Load profile data when screen is first composed
    LaunchedEffect(Unit) {
        isLoading = true
        try {
            viewModel.loadUserProfile("current_user_id") // TODO: Get from user session
            isLoading = false
        } catch (e: Exception) {
            errorMessage = e.message
            isLoading = false
        }
    }

    Box(
        modifier = androidx.compose.ui.Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        if (isLoading) {
            CircularProgressIndicator(
                modifier = androidx.compose.ui.Modifier.align(androidx.compose.ui.Alignment.Center),
                color = colorPalette.primary
            )
        } else {
            LazyColumn(
                modifier = androidx.compose.ui.Modifier.fillMaxSize(),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // Profile Header
                item {
                    ProfileHeader(
                        viewModel = viewModel,
                        colorPalette = colorPalette,
                        typography = typography
                    )
                }

                // User Details Section
                item {
                    UserDetailsSection(
                        viewModel = viewModel,
                        colorPalette = colorPalette,
                        typography = typography
                    )
                }

                // Dogs Section
                item {
                    Text(
                        text = "My Dogs",
                        style = typography.toMaterialTypography(colorPalette).titleLarge,
                        color = colorPalette.onBackground
                    )
                }

                // List of dogs
                items(viewModel.dogProfiles.value ?: emptyList()) { dog ->
                    DogCard(dog = dog)
                }

                // Bookings Section
                item {
                    Text(
                        text = "Recent Bookings",
                        style = typography.toMaterialTypography(colorPalette).titleLarge,
                        color = colorPalette.onBackground,
                        modifier = androidx.compose.ui.Modifier.padding(top = 16.dp)
                    )
                }

                // List of bookings
                items(viewModel.bookingRecords.value ?: emptyList()) { booking ->
                    BookingCard(
                        booking = booking,
                        theme = Theme(colorPalette, shapeTheme, typography)
                    )
                }

                // Logout Button
                item {
                    logoutButton.Content(
                        onClick = {
                            logoutButton.setLoading(true)
                            viewModel.logoutUser()
                            // Navigate to login screen
                            NavGraph.navigateToLogin()
                        },
                        modifier = androidx.compose.ui.Modifier
                            .fillMaxWidth()
                            .padding(vertical = 16.dp)
                    )
                }
            }

            // Error message
            errorMessage?.let { error ->
                Text(
                    text = error,
                    color = colorPalette.error,
                    style = typography.toMaterialTypography(colorPalette).bodyMedium,
                    modifier = androidx.compose.ui.Modifier
                        .align(androidx.compose.ui.Alignment.BottomCenter)
                        .padding(bottom = 16.dp)
                )
            }
        }
    }
}

@Composable
private fun ProfileHeader(
    viewModel: ProfileViewModel,
    colorPalette: ColorPalette,
    typography: Typography
) {
    Row(
        modifier = androidx.compose.ui.Modifier
            .fillMaxWidth()
            .padding(vertical = 16.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = androidx.compose.ui.Alignment.CenterVertically
    ) {
        Text(
            text = "Profile",
            style = typography.toMaterialTypography(colorPalette).headlineLarge,
            color = colorPalette.onBackground
        )

        IconButton(
            onClick = {
                // Navigate to edit profile screen
                NavGraph.navigateToEditProfile()
            }
        ) {
            Icon(
                imageVector = Icons.Default.Edit,
                contentDescription = "Edit Profile",
                tint = colorPalette.primary
            )
        }
    }
}

@Composable
private fun UserDetailsSection(
    viewModel: ProfileViewModel,
    colorPalette: ColorPalette,
    typography: Typography
) {
    val userProfile = viewModel.userProfile.value

    Column(
        modifier = androidx.compose.ui.Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp)
    ) {
        userProfile?.let { user ->
            Text(
                text = user.name,
                style = typography.toMaterialTypography(colorPalette).titleLarge,
                color = colorPalette.onBackground
            )

            Spacer(modifier = androidx.compose.ui.Modifier.height(4.dp))

            Text(
                text = user.email,
                style = typography.toMaterialTypography(colorPalette).bodyLarge,
                color = colorPalette.onBackground.copy(alpha = 0.7f)
            )

            Spacer(modifier = androidx.compose.ui.Modifier.height(4.dp))

            Text(
                text = user.phoneNumber,
                style = typography.toMaterialTypography(colorPalette).bodyLarge,
                color = colorPalette.onBackground.copy(alpha = 0.7f)
            )
        }
    }
}