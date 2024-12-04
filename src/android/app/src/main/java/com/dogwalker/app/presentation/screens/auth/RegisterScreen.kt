// androidx.compose.runtime version: 1.5.0
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue

// androidx.compose.material version: 1.5.0
import androidx.compose.material.TextField
import androidx.compose.material.Text
import androidx.compose.material.OutlinedTextField

// androidx.compose.foundation.layout version: 1.5.0
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding

// Internal imports
import com.dogwalker.app.presentation.screens.auth.RegisterViewModel
import com.dogwalker.app.presentation.theme.Theme
import com.dogwalker.app.presentation.components.LoadingButton

/**
 * Human Tasks:
 * 1. Verify that all string resources are properly externalized
 * 2. Ensure keyboard handling and input focus behavior meets UX requirements
 * 3. Test form validation error states with various input combinations
 * 4. Verify proper handling of configuration changes during registration
 */

/**
 * Composable function that provides the user interface for the registration process.
 *
 * Requirement addressed: User Management (1.3 Scope/Core Features/User Management)
 * Implements the registration screen UI allowing users to create new accounts by
 * providing their name, email, and password.
 *
 * @param viewModel The ViewModel that handles the registration business logic
 */
@Composable
fun RegisterScreen(viewModel: RegisterViewModel) {
    // State for form fields
    var name by remember { mutableStateOf("") }
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var isLoading by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf("") }

    // Create loading button instance
    val registerButton = remember { 
        LoadingButton(
            buttonText = "Register",
            isLoading = false
        )
    }

    // Observe registration state
    viewModel.registrationState.value?.let { success ->
        isLoading = false
        registerButton.setLoading(false)
        if (!success) {
            errorMessage = viewModel.errorState.value ?: "Registration failed"
        }
    }

    Column(
        modifier = androidx.compose.ui.Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        // Name input field
        OutlinedTextField(
            value = name,
            onValueChange = { name = it },
            label = { Text("Full Name") },
            modifier = androidx.compose.ui.Modifier.fillMaxWidth(),
            enabled = !isLoading,
            singleLine = true,
            textStyle = Theme.typography.bodyLarge,
            colors = androidx.compose.material.TextFieldDefaults.outlinedTextFieldColors(
                textColor = Theme.colorPalette.onBackground,
                focusedBorderColor = Theme.colorPalette.primary,
                unfocusedBorderColor = Theme.colorPalette.onBackground.copy(alpha = 0.5f)
            )
        )

        Spacer(modifier = androidx.compose.ui.Modifier.height(16.dp))

        // Email input field
        OutlinedTextField(
            value = email,
            onValueChange = { email = it },
            label = { Text("Email") },
            modifier = androidx.compose.ui.Modifier.fillMaxWidth(),
            enabled = !isLoading,
            singleLine = true,
            textStyle = Theme.typography.bodyLarge,
            colors = androidx.compose.material.TextFieldDefaults.outlinedTextFieldColors(
                textColor = Theme.colorPalette.onBackground,
                focusedBorderColor = Theme.colorPalette.primary,
                unfocusedBorderColor = Theme.colorPalette.onBackground.copy(alpha = 0.5f)
            )
        )

        Spacer(modifier = androidx.compose.ui.Modifier.height(16.dp))

        // Password input field
        OutlinedTextField(
            value = password,
            onValueChange = { password = it },
            label = { Text("Password") },
            modifier = androidx.compose.ui.Modifier.fillMaxWidth(),
            enabled = !isLoading,
            singleLine = true,
            textStyle = Theme.typography.bodyLarge,
            colors = androidx.compose.material.TextFieldDefaults.outlinedTextFieldColors(
                textColor = Theme.colorPalette.onBackground,
                focusedBorderColor = Theme.colorPalette.primary,
                unfocusedBorderColor = Theme.colorPalette.onBackground.copy(alpha = 0.5f)
            ),
            visualTransformation = androidx.compose.ui.text.input.PasswordVisualTransformation()
        )

        Spacer(modifier = androidx.compose.ui.Modifier.height(24.dp))

        // Error message display
        if (errorMessage.isNotEmpty()) {
            Text(
                text = errorMessage,
                color = Theme.colorPalette.error,
                style = Theme.typography.bodyMedium,
                modifier = androidx.compose.ui.Modifier
                    .fillMaxWidth()
                    .padding(bottom = 16.dp)
            )
        }

        // Register button
        registerButton.Content(
            onClick = {
                isLoading = true
                registerButton.setLoading(true)
                errorMessage = ""
                viewModel.register(name, email, password)
            },
            modifier = androidx.compose.ui.Modifier.fillMaxWidth(),
            enabled = name.isNotBlank() && email.isNotBlank() && password.isNotBlank()
        )
    }
}