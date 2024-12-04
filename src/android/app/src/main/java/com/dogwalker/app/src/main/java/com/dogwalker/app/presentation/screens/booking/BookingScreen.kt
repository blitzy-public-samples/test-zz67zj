// androidx.compose.material3:material3 version: 1.4.3
// androidx.compose.foundation:foundation version: 1.4.3
// androidx.compose.runtime:runtime version: 1.4.3

package com.dogwalker.app.presentation.screens.booking

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.dogwalker.app.presentation.components.BookingCard
import com.dogwalker.app.presentation.theme.Theme
import com.dogwalker.app.presentation.theme.ThemeUtils

/**
 * Human Tasks:
 * 1. Verify that Hilt dependency injection is properly configured for ViewModels
 * 2. Ensure proper error handling UI is implemented for network failures
 * 3. Test the screen with different booking list sizes for performance
 * 4. Verify accessibility features work correctly with TalkBack
 */

/**
 * BookingScreen composable that displays a list of bookings and handles user interactions.
 *
 * Requirements addressed:
 * - Booking System (1.3 Scope/Core Features/Booking System)
 *   Implements the UI for displaying and managing booking records, providing users
 *   with a clear overview of their scheduled dog walks.
 *
 * @param viewModel The ViewModel that manages the screen's state and business logic
 */
@Composable
fun BookingScreen(
    viewModel: BookingViewModel = androidx.lifecycle.viewmodel.compose.viewModel()
) {
    // Observe bookings from ViewModel
    val bookings by remember { viewModel.bookings }
    val isLoading by remember { viewModel.isLoading }
    val error by remember { viewModel.error }

    // Get theme components
    val theme = Theme(
        colorPalette = ThemeUtils.colors,
        shapeTheme = ThemeUtils.shapes,
        typography = ThemeUtils.typography
    )

    // Fetch bookings when the screen is first displayed
    LaunchedEffect(Unit) {
        viewModel.fetchBookings()
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        // Error message
        error?.let { errorMessage ->
            AlertDialog(
                onDismissRequest = { viewModel.clearError() },
                title = { Text("Error") },
                text = { Text(errorMessage) },
                confirmButton = {
                    TextButton(onClick = { viewModel.clearError() }) {
                        Text("OK")
                    }
                }
            )
        }

        // Loading indicator
        if (isLoading.value) {
            CircularProgressIndicator(
                modifier = Modifier.align(Alignment.Center),
                color = theme.colorPalette.primary
            )
        }

        // Bookings list
        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(bookings.value) { booking ->
                BookingCard(
                    booking = booking,
                    theme = theme,
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }

        // Pull to refresh functionality
        SwipeRefresh(
            state = rememberSwipeRefreshState(isLoading.value),
            onRefresh = { viewModel.fetchBookings() }
        ) {
            if (!isLoading.value && bookings.value.isEmpty()) {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "No bookings found",
                        style = theme.typography.bodyLarge,
                        color = theme.colorPalette.onBackground.copy(alpha = 0.6f)
                    )
                }
            }
        }

        // Floating action button for creating new bookings
        FloatingActionButton(
            onClick = { /* Navigate to create booking screen */ },
            modifier = Modifier
                .align(Alignment.BottomEnd)
                .padding(16.dp),
            containerColor = theme.colorPalette.primary
        ) {
            Icon(
                imageVector = Icons.Default.Add,
                contentDescription = "Create new booking",
                tint = theme.colorPalette.onPrimary
            )
        }
    }
}

/**
 * SwipeRefresh composable that provides pull-to-refresh functionality
 */
@Composable
private fun SwipeRefresh(
    state: SwipeRefreshState,
    onRefresh: () -> Unit,
    content: @Composable () -> Unit
) {
    androidx.compose.material.SwipeRefresh(
        state = state,
        onRefresh = onRefresh,
        content = content
    )
}