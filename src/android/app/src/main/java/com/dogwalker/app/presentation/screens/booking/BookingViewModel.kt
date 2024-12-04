/**
 * Human Tasks:
 * 1. Verify that Hilt dependency injection is properly configured in the application module
 * 2. Ensure proper error handling is implemented in the UI layer when consuming this ViewModel
 * 3. Consider implementing pagination if the number of bookings grows large
 * 4. Configure unit tests for this ViewModel with mock use cases
 */

package com.dogwalker.app.presentation.screens.booking

import androidx.lifecycle.LiveData // androidx.lifecycle:lifecycle-livedata-ktx:2.6.1
import androidx.lifecycle.MutableLiveData // androidx.lifecycle:lifecycle-livedata-ktx:2.6.1
import androidx.lifecycle.ViewModel // androidx.lifecycle:lifecycle-viewmodel-ktx:2.6.1
import androidx.lifecycle.viewModelScope // androidx.lifecycle:lifecycle-viewmodel-ktx:2.6.1
import com.dogwalker.app.domain.model.Booking
import com.dogwalker.app.domain.usecase.booking.GetBookingsUseCase
import dagger.hilt.android.lifecycle.HiltViewModel // dagger.hilt:hilt-android:2.44
import kotlinx.coroutines.launch // org.jetbrains.kotlinx:kotlinx-coroutines-android:1.6.4
import javax.inject.Inject

/**
 * ViewModel for managing booking-related data and UI state in the BookingScreen.
 * 
 * Requirements addressed:
 * - Booking System (1.3 Scope/Core Features/Booking System)
 *   Implements the presentation layer logic for managing and displaying booking data,
 *   providing a clean separation between the UI and domain layers.
 */
@HiltViewModel
class BookingViewModel @Inject constructor(
    private val getBookingsUseCase: GetBookingsUseCase
) : ViewModel() {

    // Private mutable LiveData to store the list of bookings
    private val _bookings = MutableLiveData<List<Booking>>()
    
    /**
     * Public immutable LiveData exposed to the UI for observing booking data changes
     *
     * Requirements addressed:
     * - Booking System (1.3 Scope/Core Features/Booking System)
     *   Provides observable booking data to the UI layer while maintaining
     *   proper encapsulation of mutable state.
     */
    val bookings: LiveData<List<Booking>> = _bookings

    // Loading state
    private val _isLoading = MutableLiveData<Boolean>()
    val isLoading: LiveData<Boolean> = _isLoading

    // Error state
    private val _error = MutableLiveData<String?>()
    val error: LiveData<String?> = _error

    /**
     * Initializes the ViewModel by fetching initial booking data
     */
    init {
        fetchBookings()
    }

    /**
     * Fetches all booking records using the GetBookingsUseCase and updates the UI state.
     *
     * Requirements addressed:
     * - Booking System (1.3 Scope/Core Features/Booking System)
     *   Implements the data fetching logic for retrieving and displaying
     *   booking records in the UI.
     */
    fun fetchBookings() {
        viewModelScope.launch {
            try {
                _isLoading.value = true
                _error.value = null
                
                // Fetch bookings using the use case
                val bookingsList = getBookingsUseCase.getBookings()
                
                // Update the LiveData with the fetched bookings
                _bookings.value = bookingsList
            } catch (e: Exception) {
                // Handle any errors that occur during fetching
                _error.value = e.message ?: "An error occurred while fetching bookings"
            } finally {
                _isLoading.value = false
            }
        }
    }

    /**
     * Clears any error state
     */
    fun clearError() {
        _error.value = null
    }

    /**
     * Refreshes the booking data by fetching the latest records
     */
    fun refresh() {
        fetchBookings()
    }
}