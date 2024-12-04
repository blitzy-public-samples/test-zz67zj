package com.dogwalker.app.presentation.screens.auth

// androidx.lifecycle version: 2.6.0
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope

// kotlinx.coroutines version: 1.6.4
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

import com.dogwalker.app.domain.usecase.auth.RegisterUseCase
import com.dogwalker.app.domain.model.User

/**
 * Human Tasks:
 * 1. Verify error handling strategy aligns with application-wide error handling policy
 * 2. Configure proper logging for registration events
 * 3. Review input validation rules with product team
 * 4. Ensure proper error message localization is implemented
 */

/**
 * ViewModel that manages the state and logic for the RegisterScreen.
 *
 * Requirement addressed: User Management (1.3 Scope/Core Features/User Management)
 * Implements the presentation layer logic for user registration by managing form state
 * and coordinating with the RegisterUseCase.
 */
class RegisterViewModel(
    private val registerUseCase: RegisterUseCase
) : ViewModel() {

    companion object {
        const val REGISTER_SUCCESS = "Registration successful"
        const val REGISTER_FAILURE = "Registration failed"
    }

    private val _registrationState = MutableLiveData<Boolean>()
    val registrationState: LiveData<Boolean> = _registrationState

    private val _errorState = MutableLiveData<String>()
    val errorState: LiveData<String> = _errorState

    /**
     * Handles the user registration process by validating inputs and invoking the RegisterUseCase.
     *
     * @param name The full name of the user
     * @param email The email address for registration
     * @param password The password for the account
     *
     * Requirement addressed: User Management (1.3 Scope/Core Features/User Management)
     * Implements user registration by validating input parameters and coordinating
     * with the RegisterUseCase to create new user accounts.
     */
    fun register(name: String, email: String, password: String) {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                // Validate inputs before proceeding
                validateInputs(name, email, password)

                // Attempt registration through the use case
                registerUseCase.execute(
                    name = name,
                    email = email,
                    password = password
                )

                // Update success state
                _registrationState.postValue(true)
                _errorState.postValue(REGISTER_SUCCESS)
            } catch (e: IllegalArgumentException) {
                // Handle validation errors
                _registrationState.postValue(false)
                _errorState.postValue(e.message ?: REGISTER_FAILURE)
            } catch (e: Exception) {
                // Handle registration errors
                _registrationState.postValue(false)
                _errorState.postValue(e.message ?: REGISTER_FAILURE)
            }
        }
    }

    /**
     * Validates the registration input parameters.
     *
     * @param name The user's full name
     * @param email The user's email address
     * @param password The user's password
     * @throws IllegalArgumentException if any validation fails
     */
    private fun validateInputs(name: String, email: String, password: String) {
        require(name.isNotBlank()) { "Name cannot be blank" }
        require(email.isNotBlank()) { "Email cannot be blank" }
        require(password.isNotBlank()) { "Password cannot be blank" }

        require(name.length <= User.MAX_NAME_LENGTH) {
            "Name cannot exceed ${User.MAX_NAME_LENGTH} characters"
        }
        require(email.length <= User.MAX_EMAIL_LENGTH) {
            "Email cannot exceed ${User.MAX_EMAIL_LENGTH} characters"
        }
        require(email.matches(Regex("[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}"))) {
            "Invalid email format"
        }
        require(password.length >= 8) { "Password must be at least 8 characters long" }
    }
}