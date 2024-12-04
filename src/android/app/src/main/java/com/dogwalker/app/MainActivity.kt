// androidx.appcompat.app version: 1.6.1
// androidx.activity.compose version: 1.6.1
package com.dogwalker.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.Composable
import com.dogwalker.app.presentation.navigation.NavGraph
import com.dogwalker.app.presentation.theme.DogWalkerTheme
import dagger.hilt.android.AndroidEntryPoint

/**
 * Human Tasks:
 * 1. Verify that the navigation graph is properly configured with all required screens
 * 2. Ensure proper theme configuration in both light and dark modes
 * 3. Test navigation flows between different screens
 * 4. Verify proper handling of configuration changes
 */

/**
 * MainActivity serves as the entry point for the Dog Walker Android application.
 * 
 * Requirements addressed:
 * - User Interface Design (8.1 User Interface Design/8.1.3 Critical User Flows)
 *   Ensures seamless navigation between screens in the Dog Walker Android application.
 * - Theming (8.1 User Interface Design/8.1.1 Design Specifications)
 *   Applies consistent theming across the application, including light and dark modes.
 */
@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    /**
     * Initializes the activity and sets up the navigation graph and UI theme.
     *
     * Requirements addressed:
     * - User Interface Design (8.1.3 Critical User Flows)
     *   Sets up the navigation infrastructure for the application.
     * - Theming (8.1.1 Design Specifications)
     *   Applies the application theme to ensure consistent styling.
     *
     * @param savedInstanceState Bundle containing the activity's previously saved state
     */
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            // Apply the application theme
            DogWalkerTheme {
                // Initialize the navigation graph
                NavGraph()
            }
        }
    }
}