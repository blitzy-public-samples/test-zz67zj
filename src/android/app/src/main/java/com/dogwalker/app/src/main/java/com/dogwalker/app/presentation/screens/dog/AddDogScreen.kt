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
 * 5. Test layout on different screen sizes and orientations
 */

/**
 * AddDogScreen composable that provides the user interface for adding a new dog profile.
 *
 * Requirements addressed:
 * - Dog Profile Management (1.3 Scope/Core Features/User Management)
 *   Implements the user interface for adding new dog profiles with proper
 *   data validation and real-time preview.
 *
 * @param viewModel ViewModel instance for managing the add dog screen state and logic
 */
@Composable
fun AddDogScreen(viewModel: AddDogViewModel) {
    // Access theme properties
    val colorPalette = Theme.LocalColorPalette.current
    val typography = Theme.LocalTypography.current
    val shapeTheme = Theme.LocalShapeTheme.current

    // State management for form fields
    var name by remember { mutableStateOf("") }
    var breed by remember { mutableStateOf("") }
    var age by remember { mutableStateOf("") }
    var isError by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf("") }

    // Collect UI state
    val state by viewModel.state.collectAsState()

    // Create preview dog instance for DogCard
    val previewDog = remember(name, breed, age) {
        Dog(
            id = UUID.randomUUID().toString(),
            name = name.ifEmpty { "Dog Name" },
            breed = breed.ifEmpty { "Breed" },
            age = age.toIntOrNull() ?: 0,
            ownerId = "" // Will be set by the ViewModel
        )
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Preview card
        DogCard(dog = previewDog)

        Spacer(modifier = Modifier.height(24.dp))

        // Form fields
        OutlinedTextField(
            value = name,
            onValueChange = { 
                name = it
                isError = false
            },
            label = { Text("Dog Name") },
            modifier = Modifier.fillMaxWidth(),
            isError = isError && name.isBlank(),
            colors = TextFieldDefaults.outlinedTextFieldColors(
                textColor = colorPalette.onBackground,
                focusedBorderColor = colorPalette.primary,
                unfocusedBorderColor = colorPalette.onBackground
            ),
            shape = MaterialTheme.shapes.medium
        )

        Spacer(modifier = Modifier.height(16.dp))

        OutlinedTextField(
            value = breed,
            onValueChange = { 
                breed = it
                isError = false
            },
            label = { Text("Breed") },
            modifier = Modifier.fillMaxWidth(),
            isError = isError && breed.isBlank(),
            colors = TextFieldDefaults.outlinedTextFieldColors(
                textColor = colorPalette.onBackground,
                focusedBorderColor = colorPalette.primary,
                unfocusedBorderColor = colorPalette.onBackground
            ),
            shape = MaterialTheme.shapes.medium
        )

        Spacer(modifier = Modifier.height(16.dp))

        OutlinedTextField(
            value = age,
            onValueChange = { 
                age = it.filter { char -> char.isDigit() }
                isError = false
            },
            label = { Text("Age") },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
            modifier = Modifier.fillMaxWidth(),
            isError = isError && (age.isBlank() || age.toIntOrNull() == null),
            colors = TextFieldDefaults.outlinedTextFieldColors(
                textColor = colorPalette.onBackground,
                focusedBorderColor = colorPalette.primary,
                unfocusedBorderColor = colorPalette.onBackground
            ),
            shape = MaterialTheme.shapes.medium
        )

        if (isError) {
            Text(
                text = errorMessage,
                color = MaterialTheme.colorScheme.error,
                style = typography.bodySmall,
                modifier = Modifier.padding(top = 4.dp)
            )
        }

        Spacer(modifier = Modifier.height(24.dp))

        Button(
            onClick = {
                if (validateForm(name, breed, age)) {
                    val newDog = Dog(
                        id = UUID.randomUUID().toString(),
                        name = name.trim(),
                        breed = breed.trim(),
                        age = age.toInt(),
                        ownerId = "" // Will be set by the ViewModel
                    )
                    viewModel.addDog(newDog)
                } else {
                    isError = true
                    errorMessage = "Please fill in all fields correctly"
                }
            },
            modifier = Modifier
                .fillMaxWidth()
                .height(56.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = colorPalette.primary,
                contentColor = colorPalette.onPrimary
            ),
            shape = MaterialTheme.shapes.medium
        ) {
            Text(
                text = "Add Dog",
                style = typography.titleMedium
            )
        }

        // Show loading indicator or error message based on state
        when (state) {
            is AddDogViewModel.AddDogState.Loading -> {
                CircularProgressIndicator(
                    modifier = Modifier.padding(16.dp),
                    color = colorPalette.primary
                )
            }
            is AddDogViewModel.AddDogState.Error -> {
                Text(
                    text = (state as AddDogViewModel.AddDogState.Error).message,
                    color = MaterialTheme.colorScheme.error,
                    style = typography.bodyMedium,
                    modifier = Modifier.padding(16.dp)
                )
            }
            else -> {}
        }
    }
}

/**
 * Validates the form input fields.
 *
 * @param name Dog's name
 * @param breed Dog's breed
 * @param age Dog's age as string
 * @return true if all fields are valid, false otherwise
 */
private fun validateForm(name: String, breed: String, age: String): Boolean {
    if (name.isBlank() || breed.isBlank() || age.isBlank()) {
        return false
    }

    val ageInt = age.toIntOrNull() ?: return false
    if (ageInt !in Dog.MIN_AGE..Dog.MAX_AGE) {
        return false
    }

    if (name.length > Dog.MAX_NAME_LENGTH) {
        return false
    }

    return true
}