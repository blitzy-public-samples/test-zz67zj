// androidx.compose.material3:material3 version: 1.1.2
// androidx.compose.ui:ui version: 1.5.4
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import com.dogwalker.app.domain.model.Dog
import com.dogwalker.app.presentation.components.DogCard
import com.dogwalker.app.presentation.screens.dog.AddDogViewModel
import com.dogwalker.app.presentation.theme.Theme
import java.util.UUID

/**
 * Human Tasks:
 * 1. Verify that Material Design 3 theme is properly configured in the app
 * 2. Ensure proper error handling and user feedback is implemented
 * 3. Test form validation with various input scenarios
 * 4. Verify accessibility features work correctly with screen readers
 * 5. Test keyboard handling and input focus behavior
 */

/**
 * AddDogScreen composable that provides the user interface for adding a new dog profile.
 *
 * Requirements addressed:
 * - Dog Profile Management (1.3 Scope/Core Features/User Management)
 *   Implements the user interface for adding new dog profiles with proper validation
 *   and real-time preview using the DogCard component.
 *
 * @param viewModel ViewModel instance for managing the add dog operation state
 */
@Composable
fun AddDogScreen(viewModel: AddDogViewModel) {
    // Access theme properties
    val colorPalette = Theme.LocalColorPalette.current
    val shapeTheme = Theme.LocalShapeTheme.current
    val typography = Theme.LocalTypography.current

    // State management for form fields
    var name by remember { mutableStateOf("") }
    var breed by remember { mutableStateOf("") }
    var age by remember { mutableStateOf("") }
    var hasError by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf("") }

    // Collect UI state
    val state by viewModel.state.collectAsState()

    // Effect to handle state changes
    LaunchedEffect(state) {
        when (state) {
            is AddDogViewModel.AddDogState.Error -> {
                hasError = true
                errorMessage = (state as AddDogViewModel.AddDogState.Error).message
            }
            is AddDogViewModel.AddDogState.Success -> {
                // Reset form after successful submission
                name = ""
                breed = ""
                age = ""
                hasError = false
                errorMessage = ""
            }
            else -> {
                hasError = false
                errorMessage = ""
            }
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Title
        Text(
            text = "Add New Dog",
            style = MaterialTheme.typography.headlineMedium,
            color = colorPalette.onBackground,
            modifier = Modifier.padding(bottom = 24.dp)
        )

        // Form fields
        OutlinedTextField(
            value = name,
            onValueChange = { 
                if (it.length <= Dog.MAX_NAME_LENGTH) name = it 
            },
            label = { Text("Dog's Name") },
            isError = hasError && name.isBlank(),
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 16.dp),
            shape = MaterialTheme.shapes.medium
        )

        OutlinedTextField(
            value = breed,
            onValueChange = { breed = it },
            label = { Text("Breed") },
            isError = hasError && breed.isBlank(),
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 16.dp),
            shape = MaterialTheme.shapes.medium
        )

        OutlinedTextField(
            value = age,
            onValueChange = { 
                if (it.isEmpty() || (it.toIntOrNull() != null && it.toInt() in Dog.MIN_AGE..Dog.MAX_AGE)) {
                    age = it
                }
            },
            label = { Text("Age (years)") },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
            isError = hasError && (age.isBlank() || age.toIntOrNull() == null),
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 24.dp),
            shape = MaterialTheme.shapes.medium
        )

        // Error message
        if (hasError) {
            Text(
                text = errorMessage,
                color = MaterialTheme.colorScheme.error,
                style = MaterialTheme.typography.bodySmall,
                modifier = Modifier.padding(bottom = 16.dp)
            )
        }

        // Preview card
        if (name.isNotBlank() || breed.isNotBlank() || age.isNotBlank()) {
            Text(
                text = "Preview",
                style = MaterialTheme.typography.titleMedium,
                modifier = Modifier.padding(bottom = 8.dp)
            )
            
            DogCard(
                dog = Dog(
                    id = UUID.randomUUID().toString(),
                    name = name.ifBlank { "Name" },
                    breed = breed.ifBlank { "Breed" },
                    age = age.toIntOrNull() ?: 0,
                    ownerId = "" // Will be set by the ViewModel
                )
            )
        }

        Spacer(modifier = Modifier.weight(1f))

        // Submit button
        Button(
            onClick = {
                if (validateInput(name, breed, age)) {
                    viewModel.addDog(
                        Dog(
                            id = UUID.randomUUID().toString(),
                            name = name.trim(),
                            breed = breed.trim(),
                            age = age.toInt(),
                            ownerId = "" // Will be set by the ViewModel
                        )
                    )
                } else {
                    hasError = true
                    errorMessage = "Please fill in all fields correctly"
                }
            },
            modifier = Modifier
                .fillMaxWidth()
                .height(56.dp),
            enabled = state !is AddDogViewModel.AddDogState.Loading,
            shape = MaterialTheme.shapes.medium
        ) {
            if (state is AddDogViewModel.AddDogState.Loading) {
                CircularProgressIndicator(
                    color = MaterialTheme.colorScheme.onPrimary,
                    modifier = Modifier.size(24.dp)
                )
            } else {
                Text("Add Dog")
            }
        }
    }
}

/**
 * Validates the input fields for the add dog form.
 *
 * @param name Dog's name
 * @param breed Dog's breed
 * @param age Dog's age
 * @return true if all inputs are valid, false otherwise
 */
private fun validateInput(name: String, breed: String, age: String): Boolean {
    return name.isNotBlank() &&
           name.length <= Dog.MAX_NAME_LENGTH &&
           breed.isNotBlank() &&
           age.isNotBlank() &&
           age.toIntOrNull() != null &&
           age.toInt() in Dog.MIN_AGE..Dog.MAX_AGE
}