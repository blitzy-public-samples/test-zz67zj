/**
 * Human Tasks:
 * 1. Verify that all required use cases are properly injected through Dagger/Hilt
 * 2. Ensure proper error handling is implemented in the UI layer when observing LiveData
 * 3. Configure coroutine exception handling strategy for the ViewModel scope
 * 4. Set up unit tests for the ViewModel with mock use cases
 */

package com.dogwalker.app.presentation.screens.home

// AndroidX Lifecycle - version 2.6.1
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel

// Coroutines - version 1.6.4
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

// Domain models
import com.dogwalker.app.domain.model.Booking
import com.dogwalker.app.domain.model.Dog
import com.dogwalker.app.domain.model.Location

// Use cases
import com.dogwalker.app.domain.usecase.booking.GetBookingsUseCase
import com.dogwalker.app.domain.usecase.walk.TrackWalkUseCase
import com.dogwalker.app.domain.usecase.dog.GetDogsUseCase

import javax.inject.Inject

/**
 * ViewModel class that manages the state and business logic for the Home screen.
 * 
 * Requirements addressed:
 * - User Dashboard (1.3 Scope/Core Features/User Management)
 *   Implements the presentation layer logic for displaying and managing bookings,
 *   dogs, and active walks in a centralized dashboard view.
 * 
 * - Service Execution (1.3 Scope/Core Features/Service Execution)
 *   Provides functionality to track and display active walks including GPS
 *   location updates and route recording.
 */
class HomeViewModel @Inject constructor(
    private val getBookingsUseCase: GetBookingsUseCase,
    private val trackWalkUseCase: TrackWalkUseCase,
    private val getDogsUseCase: GetDogsUseCase
) : ViewModel() {

    // Bookings LiveData
    private val _bookings = MutableLiveData<List<Booking>>()
    val bookings: LiveData<List<Booking>> = _bookings

    // Dogs LiveData
    private val _dogs = MutableLiveData<List<Dog>>()
    val dogs: LiveData<List<Dog>> = _dogs

    // Active walk route LiveData
    private val _activeWalkRoute = MutableLiveData<List<Location>>()
    val activeWalkRoute: LiveData<List<Location>> = _activeWalkRoute

    // Error state LiveData
    private val _error = MutableLiveData<String>()
    val error: LiveData<String> = _error

    // Loading state LiveData
    private val _isLoading = MutableLiveData<Boolean>()
    val isLoading: LiveData<Boolean> = _isLoading

    /**
     * Loads all bookings for the user and updates the LiveData.
     * 
     * Requirements addressed:
     * - User Dashboard (1.3 Scope/Core Features/User Management)
     *   Retrieves and displays all booking records in the dashboard view.
     */
    fun loadBookings() {
        _isLoading.value = true
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val bookingsList = getBookingsUseCase.getBookings()
                _bookings.postValue(bookingsList)
            } catch (e: Exception) {
                _error.postValue("Failed to load bookings: ${e.message}")
            } finally {
                _isLoading.postValue(false)
            }
        }
    }

    /**
     * Loads all dog profiles for the user and updates the LiveData.
     * 
     * Requirements addressed:
     * - User Dashboard (1.3 Scope/Core Features/User Management)
     *   Retrieves and displays all dog profiles in the dashboard view.
     */
    fun loadDogs() {
        _isLoading.value = true
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val dogsList = getDogsUseCase.execute()
                _dogs.postValue(dogsList)
            } catch (e: Exception) {
                _error.postValue("Failed to load dogs: ${e.message}")
            } finally {
                _isLoading.postValue(false)
            }
        }
    }

    /**
     * Tracks the active walk and updates the LiveData with the route.
     * 
     * Requirements addressed:
     * - Service Execution (1.3 Scope/Core Features/Service Execution)
     *   Implements live GPS tracking and route recording for active walks.
     *
     * @param walkId The unique identifier of the walk to track
     */
    fun trackActiveWalk(walkId: String) {
        require(walkId.isNotBlank()) { "Walk ID cannot be blank" }

        CoroutineScope(Dispatchers.IO).launch {
            try {
                // Start tracking the walk location
                trackWalkUseCase.trackLocation(
                    walkId = walkId,
                    latitude = 0.0, // These will be replaced with actual GPS coordinates
                    longitude = 0.0,
                    timestamp = System.currentTimeMillis()
                )

                // Get the updated route
                val route = trackWalkUseCase.getRoute(walkId)
                _activeWalkRoute.postValue(route)
            } catch (e: Exception) {
                _error.postValue("Failed to track walk: ${e.message}")
            }
        }
    }

    /**
     * Clears any error messages in the error LiveData.
     */
    fun clearError() {
        _error.value = null
    }

    companion object {
        /**
         * Minimum interval between route updates in milliseconds
         */
        private const val ROUTE_UPDATE_INTERVAL_MS = 5000L // 5 seconds
    }
}