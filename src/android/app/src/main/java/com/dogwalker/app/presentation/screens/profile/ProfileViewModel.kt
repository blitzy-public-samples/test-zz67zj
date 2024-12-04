package com.dogwalker.app.presentation.screens.profile

// androidx.lifecycle v2.6.1
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel

// kotlinx.coroutines v1.6.4
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

// Internal imports
import com.dogwalker.app.domain.usecase.auth.LoginUseCase
import com.dogwalker.app.domain.usecase.auth.LogoutUseCase
import com.dogwalker.app.domain.usecase.dog.GetDogsUseCase
import com.dogwalker.app.domain.usecase.booking.GetBookingsUseCase
import com.dogwalker.app.data.repository.UserRepository
import com.dogwalker.app.domain.model.User
import com.dogwalker.app.domain.model.Dog
import com.dogwalker.app.domain.model.Booking

/**
 * Human Tasks:
 * 1. Verify proper error handling strategy aligns with application-wide error handling policy
 * 2. Configure logging for profile-related operations and state changes
 * 3. Set up unit tests for ViewModel with mock dependencies
 * 4. Review coroutine scope management and lifecycle handling
 */

/**
 * ViewModel that manages the state and business logic for the Profile screen.
 *
 * Requirements addressed:
 * - User Management (1.3 Scope/Core Features/User Management)
 *   Manages user profile data and provides functionality for profile updates
 * - Dog Profile Management (1.3 Scope/Core Features/User Management)
 *   Handles retrieval and display of associated dog profiles
 * - Booking Management (1.3 Scope/Core Features/Booking System)
 *   Manages the retrieval and display of user's booking records
 */
class ProfileViewModel(
    private val loginUseCase: LoginUseCase,
    private val logoutUseCase: LogoutUseCase,
    private val getDogsUseCase: GetDogsUseCase,
    private val getBookingsUseCase: GetBookingsUseCase,
    private val userRepository: UserRepository
) : ViewModel() {

    private val viewModelScope = CoroutineScope(Dispatchers.Main)

    // LiveData for user profile
    private val _userProfile = MutableLiveData<User>()
    val userProfile: LiveData<User> = _userProfile

    // LiveData for dog profiles
    private val _dogProfiles = MutableLiveData<List<Dog>>()
    val dogProfiles: LiveData<List<Dog>> = _dogProfiles

    // LiveData for booking records
    private val _bookingRecords = MutableLiveData<List<Booking>>()
    val bookingRecords: LiveData<List<Booking>> = _bookingRecords

    // Error handling
    private val _error = MutableLiveData<String>()
    val error: LiveData<String> = _error

    // Loading state
    private val _isLoading = MutableLiveData<Boolean>()
    val isLoading: LiveData<Boolean> = _isLoading

    /**
     * Loads the user's profile data, including associated dogs and booking records.
     *
     * Requirements addressed:
     * - User Management (1.3 Scope/Core Features/User Management)
     * - Dog Profile Management (1.3 Scope/Core Features/User Management)
     * - Booking Management (1.3 Scope/Core Features/Booking System)
     *
     * @param userId The unique identifier of the user whose profile is to be loaded
     */
    fun loadUserProfile(userId: String) {
        viewModelScope.launch {
            try {
                _isLoading.value = true

                // Load user profile
                withContext(Dispatchers.IO) {
                    val user = userRepository.getUserById(userId)
                    user?.let {
                        _userProfile.postValue(it)
                        
                        // Load associated dogs
                        val dogs = getDogsUseCase.execute()
                        _dogProfiles.postValue(dogs)

                        // Load booking records
                        val bookings = getBookingsUseCase.getBookings()
                        _bookingRecords.postValue(bookings)
                    } ?: run {
                        _error.postValue("User not found")
                    }
                }
            } catch (e: Exception) {
                _error.value = "Failed to load profile: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }

    /**
     * Updates the user's profile information in the database.
     *
     * Requirement addressed: User Management (1.3 Scope/Core Features/User Management)
     *
     * @param user The updated User object containing the new profile information
     * @return Boolean indicating whether the update was successful
     */
    suspend fun updateUserProfile(user: User): Boolean {
        return try {
            withContext(Dispatchers.IO) {
                userRepository.updateUser(user)
                _userProfile.postValue(user)
                true
            }
        } catch (e: Exception) {
            _error.postValue("Failed to update profile: ${e.message}")
            false
        }
    }

    /**
     * Logs out the current user by clearing their session data.
     *
     * Requirement addressed: User Management (1.3 Scope/Core Features/User Management)
     *
     * @return Boolean indicating whether the logout was successful
     */
    suspend fun logoutUser(): Boolean {
        return try {
            withContext(Dispatchers.IO) {
                val result = logoutUseCase.logout()
                if (result) {
                    // Clear all profile data
                    _userProfile.postValue(null)
                    _dogProfiles.postValue(emptyList())
                    _bookingRecords.postValue(emptyList())
                }
                result
            }
        } catch (e: Exception) {
            _error.postValue("Failed to logout: ${e.message}")
            false
        }
    }

    override fun onCleared() {
        super.onCleared()
        // Clean up any resources if needed
    }
}