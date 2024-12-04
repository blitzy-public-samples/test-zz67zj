// androidx.compose.runtime version: 1.5.0
import androidx.compose.foundation.layout.*
import androidx.compose.material.*
import androidx.compose.runtime.*
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
 * Requirement addressed: User Management (1.3 Scope/Core Features/User Management)
 * - Provides user authentication interface
 * - Supports email/password login
 * - Implements Material Design guidelines
 * - Ensures accessibility compliance
 *
 * @param viewModel The ViewModel handling login business logic
 */
@Composable
fun LoginScreen(
    viewModel: LoginViewModel
) {
    // State management
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var isLoading by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf<String?>(null) }

    // Theme components
    val colorPalette = Theme.LocalColorPalette.current
    val typography = Theme.LocalTypography.current

    // Loading button instance
    val loginButton = remember { 
        LoadingButton(
            buttonText = "Sign In",
            isLoading = false
        )
    }

    // Observe login state
    LaunchedEffect(viewModel.loginState.value) {
        viewModel.loginState.value?.let { success ->
            isLoading = false
            loginButton.setLoading(false)
            if (!success) {
                errorMessage = viewModel.errorState.value
            }
        }
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
        OutlinedTextField(
            value = email,
            onValueChange = { 
                email = it
                errorMessage = null
            },
            label = { Text("Email") },
            modifier = Modifier.fillMaxWidth(),
            singleLine = true,
            enabled = !isLoading,
            colors = TextFieldDefaults.outlinedTextFieldColors(
                focusedBorderColor = colorPalette.primary,
                unfocusedBorderColor = colorPalette.onBackground.copy(alpha = 0.5f)
            )
        )

        Spacer(modifier = Modifier.height(16.dp))

        // Password input field
        OutlinedTextField(
            value = password,
            onValueChange = { 
                password = it
                errorMessage = null
            },
            label = { Text("Password") },
            visualTransformation = PasswordVisualTransformation(),
            modifier = Modifier.fillMaxWidth(),
            singleLine = true,
            enabled = !isLoading,
            colors = TextFieldDefaults.outlinedTextFieldColors(
                focusedBorderColor = colorPalette.primary,
                unfocusedBorderColor = colorPalette.onBackground.copy(alpha = 0.5f)
            )
        )

        Spacer(modifier = Modifier.height(8.dp))

        // Error message display
        errorMessage?.let { error ->
            Text(
                text = error,
                color = colorPalette.error,
                style = typography.toMaterialTypography(colorPalette).bodySmall,
                modifier = Modifier.padding(vertical = 8.dp)
            )
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Login button
        loginButton.Content(
            onClick = {
                if (validateInput(email, password)) {
                    isLoading = true
                    loginButton.setLoading(true)
                    errorMessage = null
                    viewModel.login(email, password)
                } else {
                    errorMessage = "Please enter a valid email and password"
                }
            },
            modifier = Modifier.fillMaxWidth(),
            enabled = !isLoading && email.isNotEmpty() && password.isNotEmpty()
        )
    }
}

/**
 * Validates user input for email and password.
 *
 * @param email The email to validate
 * @param password The password to validate
 * @return Boolean indicating if the input is valid
 */
private fun validateInput(email: String, password: String): Boolean {
    val emailPattern = "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}"
    return email.matches(emailPattern.toRegex()) && password.length >= 8
}