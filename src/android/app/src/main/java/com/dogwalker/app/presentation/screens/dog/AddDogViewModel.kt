package com.dogwalker.app.presentation.screens.dog

import androidx.lifecycle.ViewModel // androidx.lifecycle:lifecycle-viewmodel-ktx:2.6.1
import androidx.lifecycle.viewModelScope // androidx.lifecycle:lifecycle-viewmodel-ktx:2.6.1
import com.dogwalker.app.domain.model.Dog
import com.dogwalker.app.domain.usecase.dog.AddDogUseCase
import dagger.hilt.android.lifecycle.HiltViewModel // dagger.hilt:hilt-android:2.44
import kotlinx.coroutines.flow.MutableStateFlow // org.jetbrains.kotlinx:kotlinx-coroutines-core:1.6.4
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 * Human Tasks:
 * 1. Verify that Hilt dependency injection is properly configured in the application
 * 2. Ensure proper error handling is implemented in the UI layer when calling ViewModel methods
 * 3. Consider implementing unit tests to verify validation logic and state management
 * 4. Review error messages for user-friendliness and localization needs
 */

/**
 * ViewModel responsible for managing the state and business logic for adding new dog profiles.
 *
 * Requirements addressed:
 * - Dog Profile Management (1.3 Scope/Core Features/User Management)
 *   Implements the presentation layer logic for adding new dog profiles, managing UI state,
 *   and coordinating with the domain layer through the AddDogUseCase.
 */
@HiltViewModel
class AddDogViewModel @Inject constructor(
    private val addDogUseCase: AddDogUseCase
) : ViewModel() {

    /**
     * Sealed class representing the different states of the add dog operation
     */
    sealed class AddDogState {
        object Idle : AddDogState()
        object Loading : AddDogState()
        object Success : AddDogState()
        data class Error(val message: String) : AddDogState()
    }

    private val _state = MutableStateFlow<AddDogState>(AddDogState.Idle)
    val state: StateFlow<AddDogState> = _state.asStateFlow()

    /**
     * Handles the addition of a new dog profile.
     *
     * Requirements addressed:
     * - Dog Profile Management (1.3 Scope/Core Features/User Management)
     *   Implements the logic for validating and adding new dog profiles through
     *   the AddDogUseCase while managing the UI state.
     *
     * @param dog The Dog object containing the profile information to be added
     */
    fun addDog(dog: Dog) {
        viewModelScope.launch {
            try {
                _state.value = AddDogState.Loading

                // Additional view model level validation
                validateDog(dog)

                // Execute the use case to add the dog
                addDogUseCase.execute(dog)

                _state.value = AddDogState.Success
            } catch (e: IllegalArgumentException) {
                _state.value = AddDogState.Error(e.message ?: "Invalid dog profile data")
            } catch (e: Exception) {
                _state.value = AddDogState.Error("Failed to add dog profile: ${e.message}")
            }
        }
    }

    /**
     * Validates the dog profile data before attempting to add it.
     *
     * @param dog The Dog object to validate
     * @throws IllegalArgumentException if validation fails
     */
    private fun validateDog(dog: Dog) {
        require(dog.name.length <= Dog.MAX_NAME_LENGTH) {
            "Dog name cannot exceed ${Dog.MAX_NAME_LENGTH} characters"
        }

        require(dog.age in Dog.MIN_AGE..Dog.MAX_AGE) {
            "Dog age must be between ${Dog.MIN_AGE} and ${Dog.MAX_AGE} years"
        }

        require(dog.breed.isNotBlank()) {
            "Dog breed cannot be blank"
        }

        require(dog.ownerId.isNotBlank()) {
            "Owner ID cannot be blank"
        }
    }

    /**
     * Resets the state to idle.
     * Useful when navigating away from the add dog screen or when preparing for a new operation.
     */
    fun resetState() {
        _state.value = AddDogState.Idle
    }
}