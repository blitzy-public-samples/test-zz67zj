// androidx.compose.runtime version: 1.5.0
// androidx.compose.material version: 1.5.0
// androidx.compose.foundation.layout version: 1.5.0

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material.MaterialTheme
import androidx.compose.material.Text
import androidx.compose.material.TextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import com.dogwalker.app.presentation.components.LoadingButton
import com.dogwalker.app.presentation.theme.Theme

/**
 * Human Tasks:
 * 1. Verify that the API endpoint for authentication is properly configured
 * 2. Ensure proper error handling for network failures is implemented
 * 3. Test accessibility features with TalkBack enabled
 * 4. Verify that password requirements meet security standards
 */

/**
 * LoginScreen composable that provides the user interface for authentication.
 * 
 * Requirement addressed: 1.3 Scope/Core Features/User Management
 * - Provides user authentication interface
 * - Supports email/password login
 * - Implements Material Design 3 guidelines
 * - Ensures accessibility compliance
 */
@Composable
fun LoginScreen() {
    // State management for form fields
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var isLoading by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf<String?>(null) }

    // Initialize theme components
    val colorPalette = Theme.colorPalette
    val typography = Theme.typography

    // Create loading button instance
    val loginButton = remember { 
        LoadingButton(
            buttonText = "Sign In",
            isLoading = false
        )
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(modifier = Modifier.height(48.dp))

        // App title
        Text(
            text = "Dog Walker",
            style = typography.toMaterialTypography(colorPalette).headlineMedium,
            color = colorPalette.onBackground
        )

        Spacer(modifier = Modifier.height(48.dp))

        // Email input field
        TextField(
            value = email,
            onValueChange = { 
                email = it
                errorMessage = null
            },
            label = { Text("Email") },
            modifier = Modifier.fillMaxWidth(),
            singleLine = true,
            enabled = !isLoading
        )

        Spacer(modifier = Modifier.height(16.dp))

        // Password input field
        TextField(
            value = password,
            onValueChange = { 
                password = it
                errorMessage = null
            },
            label = { Text("Password") },
            visualTransformation = PasswordVisualTransformation(),
            modifier = Modifier.fillMaxWidth(),
            singleLine = true,
            enabled = !isLoading
        )

        Spacer(modifier = Modifier.height(8.dp))

        // Error message display
        errorMessage?.let { error ->
            Text(
                text = error,
                color = colorPalette.onBackground,
                style = typography.toMaterialTypography(colorPalette).bodySmall,
                modifier = Modifier.padding(vertical = 8.dp)
            )
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Login button
        loginButton.Content(
            onClick = {
                if (validateInput(email, password)) {
                    performLogin(
                        email = email,
                        password = password,
                        onLoading = { isLoading ->
                            loginButton.setLoading(isLoading)
                        },
                        onError = { message ->
                            errorMessage = message
                        },
                        onSuccess = {
                            // Navigate to main screen on successful login
                            ScreenNavGraph("main")
                        }
                    )
                } else {
                    errorMessage = "Please enter valid email and password"
                }
            },
            modifier = Modifier.fillMaxWidth(),
            enabled = !isLoading && email.isNotEmpty() && password.isNotEmpty()
        )
    }
}

/**
 * Validates user input for email and password
 */
private fun validateInput(email: String, password: String): Boolean {
    val emailPattern = "[a-zA-Z0-9._-]+@[a-z]+\\.+[a-z]+"
    return email.matches(emailPattern.toRegex()) && password.length >= 8
}

/**
 * Handles the login process
 */
private fun performLogin(
    email: String,
    password: String,
    onLoading: (Boolean) -> Unit,
    onError: (String) -> Unit,
    onSuccess: () -> Unit
) {
    onLoading(true)
    
    try {
        // TODO: Implement actual API call for authentication
        // This is a placeholder for the actual implementation
        // that would integrate with the backend authentication service
        
        // Simulated API call delay
        android.os.Handler().postDelayed({
            onLoading(false)
            // For demonstration, always succeed
            onSuccess()
        }, 1500)
    } catch (e: Exception) {
        onLoading(false)
        onError("Login failed. Please try again.")
    }
}