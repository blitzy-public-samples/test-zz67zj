// androidx.lifecycle:lifecycle-viewmodel-ktx:2.6.1
import androidx.lifecycle.ViewModel
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData

// kotlinx.coroutines:coroutines-android:1.6.4
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.coroutines.launch

import com.dogwalker.app.domain.usecase.walk.StartWalkUseCase
import com.dogwalker.app.domain.usecase.walk.EndWalkUseCase
import com.dogwalker.app.domain.usecase.walk.TrackWalkUseCase
import com.dogwalker.app.domain.model.Walk
import com.dogwalker.app.domain.model.Location

/**
 * Human Tasks:
 * 1. Configure proper error handling and display in the UI layer
 * 2. Ensure location permissions are properly requested before starting walk tracking
 * 3. Verify that the location update frequency matches battery optimization requirements
 * 4. Set up proper lifecycle management for location updates in the UI layer
 */

/**
 * ViewModel responsible for managing the state and business logic of the Active Walk screen.
 *
 * Requirements addressed:
 * - Service Execution (1.3 Scope/Core Features/Service Execution)
 *   Implements live GPS tracking, walk initiation, and walk completion functionalities
 * - User Interface Design (8.1.1 Design Specifications)
 *   Ensures consistent state management and interaction for the Active Walk screen
 */
class ActiveWalkViewModel(
    private val startWalkUseCase: StartWalkUseCase,
    private val endWalkUseCase: EndWalkUseCase,
    private val trackWalkUseCase: TrackWalkUseCase
) : ViewModel() {

    private val viewModelScope = CoroutineScope(Dispatchers.Main)

    // LiveData for the current walk session
    private val _currentWalk = MutableLiveData<Walk>()
    val currentWalk: LiveData<Walk> = _currentWalk

    // LiveData for the walk route (list of locations)
    private val _walkRoute = MutableLiveData<List<Location>>()
    val walkRoute: LiveData<List<Location>> = _walkRoute

    // LiveData for error states
    private val _errorState = MutableLiveData<String>()
    val errorState: LiveData<String> = _errorState

    /**
     * Initiates a new walk session.
     *
     * Requirements addressed:
     * - Service Execution (1.3)
     *   Handles walk initiation with proper error handling and state management
     *
     * @param userId ID of the walker initiating the walk
     * @param dogId ID of the dog being walked
     * @param bookingId ID of the associated booking
     * @param initialLocation Initial GPS location of the walk
     * @return LiveData containing the newly created Walk entity
     */
    fun startWalk(
        userId: String,
        dogId: String,
        bookingId: String,
        initialLocation: Location
    ): LiveData<Walk> {
        viewModelScope.launch {
            try {
                withContext(Dispatchers.IO) {
                    val walk = startWalkUseCase.startWalk(
                        userId = userId,
                        dogId = dogId,
                        bookingId = bookingId,
                        initialLocation = initialLocation
                    )
                    _currentWalk.postValue(walk)
                }
            } catch (e: Exception) {
                _errorState.postValue("Failed to start walk: ${e.message}")
            }
        }
        return currentWalk
    }

    /**
     * Ends the current walk session.
     *
     * Requirements addressed:
     * - Service Execution (1.3)
     *   Handles walk completion with proper state updates and error handling
     *
     * @param walkId ID of the walk to end
     * @param endTime End time of the walk in ISO 8601 format
     * @return LiveData containing the updated Walk entity
     */
    fun endWalk(walkId: String, endTime: String): LiveData<Walk> {
        viewModelScope.launch {
            try {
                withContext(Dispatchers.IO) {
                    val updatedWalk = endWalkUseCase.endWalk(
                        walkId = walkId,
                        endTime = endTime
                    )
                    _currentWalk.postValue(updatedWalk)
                }
            } catch (e: Exception) {
                _errorState.postValue("Failed to end walk: ${e.message}")
            }
        }
        return currentWalk
    }

    /**
     * Tracks the current location during a walk session.
     *
     * Requirements addressed:
     * - Service Execution (1.3)
     *   Implements real-time GPS tracking with route updates and error handling
     *
     * @param walkId ID of the walk being tracked
     * @param latitude Current latitude coordinate
     * @param longitude Current longitude coordinate
     * @param timestamp Unix timestamp of the location update
     * @return LiveData containing the updated list of locations
     */
    fun trackWalk(
        walkId: String,
        latitude: Double,
        longitude: Double,
        timestamp: Long
    ): LiveData<List<Location>> {
        viewModelScope.launch {
            try {
                withContext(Dispatchers.IO) {
                    // Track the new location
                    trackWalkUseCase.trackLocation(
                        walkId = walkId,
                        latitude = latitude,
                        longitude = longitude,
                        timestamp = timestamp
                    )

                    // Retrieve and update the complete route
                    val updatedRoute = trackWalkUseCase.getRoute(walkId)
                    _walkRoute.postValue(updatedRoute)
                }
            } catch (e: Exception) {
                _errorState.postValue("Failed to track location: ${e.message}")
            }
        }
        return walkRoute
    }

    companion object {
        /**
         * Minimum time interval between location updates in milliseconds
         */
        const val MIN_LOCATION_UPDATE_INTERVAL = TrackWalkUseCase.MIN_UPDATE_INTERVAL_MS

        /**
         * Maximum time interval between location updates in milliseconds
         */
        const val MAX_LOCATION_UPDATE_INTERVAL = TrackWalkUseCase.MAX_UPDATE_INTERVAL_MS
    }
}