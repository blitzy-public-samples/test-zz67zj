// androidx.lifecycle version: 2.6.0
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope

// kotlinx.coroutines version: 1.6.4
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

import com.dogwalker.app.domain.usecase.auth.LoginUseCase

/**
 * Human Tasks:
 * 1. Verify error handling strategy aligns with application-wide error handling policy
 * 2. Configure proper logging for authentication events
 * 3. Ensure proper unit test coverage for authentication flows
 */

/**
 * ViewModel that manages the state and logic for the LoginScreen.
 *
 * Requirement addressed: User Management (1.3 Scope/Core Features/User Management)
 * Implements the presentation layer logic for user authentication by managing form state
 * and coordinating with the LoginUseCase.
 */
class LoginViewModel(
    private val loginUseCase: LoginUseCase
) : ViewModel() {

    companion object {
        const val LOGIN_SUCCESS = "Login successful"
        const val LOGIN_FAILURE = "Login failed"
    }

    // Private mutable state
    private val _loginState = MutableLiveData<Boolean>()
    private val _errorState = MutableLiveData<String>()

    // Public immutable state
    val loginState: LiveData<Boolean> = _loginState
    val errorState: LiveData<String> = _errorState

    /**
     * Handles the login process by validating inputs and invoking the LoginUseCase.
     *
     * Requirement addressed: User Management (1.3 Scope/Core Features/User Management)
     * Implements user authentication by validating credentials and coordinating
     * with the LoginUseCase to authenticate users.
     *
     * @param email The user's email address
     * @param password The user's password
     */
    fun login(email: String, password: String) {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                // Validate inputs before proceeding
                validateInputs(email, password)

                // Attempt login through use case
                loginUseCase.execute(
                    email = email,
                    password = password
                )

                // Update success state
                _loginState.postValue(true)
                _errorState.postValue(LOGIN_SUCCESS)
            } catch (e: IllegalArgumentException) {
                // Handle validation errors
                _loginState.postValue(false)
                _errorState.postValue(e.message ?: LOGIN_FAILURE)
            } catch (e: Exception) {
                // Handle login errors
                _loginState.postValue(false)
                _errorState.postValue(e.message ?: LOGIN_FAILURE)
            }
        }
    }

    /**
     * Validates the login input parameters.
     *
     * @param email The user's email address
     * @param password The user's password
     * @throws IllegalArgumentException if any validation fails
     */
    private fun validateInputs(email: String, password: String) {
        require(email.isNotBlank()) { "Email cannot be blank" }
        require(password.isNotBlank()) { "Password cannot be blank" }
        require(email.matches(Regex("[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}"))) {
            "Invalid email format"
        }
        require(password.length >= 8) { "Password must be at least 8 characters long" }
    }
}