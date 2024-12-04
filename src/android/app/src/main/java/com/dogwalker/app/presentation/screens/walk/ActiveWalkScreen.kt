// androidx.fragment.app version: 1.6.1
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider // androidx.lifecycle version: 2.6.1
import androidx.lifecycle.LiveData // androidx.lifecycle version: 2.6.1
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.util.Log

// Internal imports
import com.dogwalker.app.presentation.screens.walk.ActiveWalkViewModel
import com.dogwalker.app.presentation.components.MapViewComponent
import com.dogwalker.app.presentation.components.LoadingButton
import com.dogwalker.app.presentation.components.RatingBar
import com.dogwalker.app.domain.model.Location
import com.dogwalker.app.util.LocationUtils

/**
 * Human Tasks:
 * 1. Verify that Google Maps API key is properly configured in AndroidManifest.xml
 * 2. Ensure location permissions are properly requested before starting walk tracking
 * 3. Test walk tracking functionality on different Android versions and devices
 * 4. Verify that the walk session properly ends when the app is terminated
 */

/**
 * ActiveWalkScreen class responsible for rendering the Active Walk screen.
 * 
 * Requirements addressed:
 * - Service Execution (1.3 Scope/Core Features/Service Execution)
 *   Implements live GPS tracking, walk initiation, and walk completion functionalities
 * - User Interface Design (8.1.1 Design Specifications)
 *   Ensures consistent and interactive UI for the Active Walk screen
 */
class ActiveWalkScreen : Fragment() {
    private val TAG = "ActiveWalkScreen"

    // ViewModel instance
    private lateinit var viewModel: ActiveWalkViewModel

    // UI Components
    private lateinit var mapViewComponent: MapViewComponent
    private lateinit var startEndButton: LoadingButton
    private lateinit var ratingBar: RatingBar

    // Track walk state
    private var isWalkActive = false
    private var currentWalkId: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        viewModel = ViewModelProvider(this)[ActiveWalkViewModel::class.java]
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        // Initialize UI components
        initializeScreen()
        return super.onCreateView(inflater, container, savedInstanceState)
    }

    /**
     * Initializes the Active Walk screen by setting up UI components and observers.
     * 
     * Requirements addressed:
     * - User Interface Design (8.1.1)
     *   Sets up interactive UI components following design specifications
     */
    private fun initializeScreen() {
        try {
            // Initialize map component
            context?.let { ctx ->
                mapViewComponent = MapViewComponent(ctx)
                mapViewComponent.initializeMap(ctx)
            }

            // Initialize start/end button
            startEndButton = LoadingButton(
                buttonText = "Start Walk",
                isLoading = false
            )

            // Initialize rating bar (initially hidden)
            context?.let { ctx ->
                ratingBar = RatingBar(
                    colorPalette = com.dogwalker.app.presentation.theme.ColorPalette(),
                    shapeTheme = com.dogwalker.app.presentation.theme.ShapeTheme(),
                    typography = com.dogwalker.app.presentation.theme.Typography(),
                    onRatingChanged = { rating ->
                        // Handle rating change
                        Log.d(TAG, "Walk rated: $rating stars")
                    }
                )
            }

            // Set up observers
            setupObservers()

            // Set up button click listener
            startEndButton.Content(
                onClick = {
                    if (isWalkActive) {
                        endWalk()
                    } else {
                        startWalk()
                    }
                }
            )

        } catch (e: Exception) {
            Log.e(TAG, "Error initializing screen", e)
        }
    }

    /**
     * Sets up LiveData observers for walk state updates.
     */
    private fun setupObservers() {
        // Observe current walk
        viewModel.currentWalk.observe(viewLifecycleOwner) { walk ->
            walk?.let {
                currentWalkId = it.id
                isWalkActive = it.status == "in_progress"
                updateButtonState()
            }
        }

        // Observe walk route
        viewModel.walkRoute.observe(viewLifecycleOwner) { locations ->
            locations?.let {
                if (it.isNotEmpty()) {
                    val lastLocation = it.last()
                    mapViewComponent.updateUserLocation(
                        android.location.Location("").apply {
                            latitude = lastLocation.latitude
                            longitude = lastLocation.longitude
                        }
                    )
                }
            }
        }

        // Observe errors
        viewModel.errorState.observe(viewLifecycleOwner) { error ->
            error?.let {
                Log.e(TAG, "Error in walk session: $it")
                // TODO: Show error to user
            }
        }
    }

    /**
     * Starts a new walk session.
     * 
     * Requirements addressed:
     * - Service Execution (1.3)
     *   Handles walk initiation with proper state management
     */
    private fun startWalk() {
        startEndButton.setLoading(true)

        context?.let { ctx ->
            if (!LocationUtils.isLocationPermissionGranted(ctx)) {
                Log.e(TAG, "Location permissions not granted")
                startEndButton.setLoading(false)
                return
            }

            // Get current location and start walk
            viewLifecycleOwner.lifecycle.coroutineScope.launch {
                try {
                    val location = LocationUtils.getCurrentLocation(ctx)
                    location?.let {
                        val dogWalkerLocation = Location(
                            id = java.util.UUID.randomUUID().toString(),
                            latitude = it.latitude,
                            longitude = it.longitude,
                            userId = "current_user_id", // TODO: Get from user session
                            walkId = "",
                            timestamp = System.currentTimeMillis()
                        )

                        viewModel.startWalk(
                            userId = "current_user_id", // TODO: Get from user session
                            dogId = "current_dog_id", // TODO: Get from intent
                            bookingId = "current_booking_id", // TODO: Get from intent
                            initialLocation = dogWalkerLocation
                        )

                        startEndButton.setText("End Walk")
                        startEndButton.setLoading(false)
                        isWalkActive = true
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error starting walk", e)
                    startEndButton.setLoading(false)
                }
            }
        }
    }

    /**
     * Ends the current walk session.
     * 
     * Requirements addressed:
     * - Service Execution (1.3)
     *   Handles walk completion with proper cleanup
     */
    private fun endWalk() {
        startEndButton.setLoading(true)

        currentWalkId?.let { walkId ->
            viewModel.endWalk(
                walkId = walkId,
                endTime = java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", 
                    java.util.Locale.getDefault()).format(java.util.Date())
            )

            mapViewComponent.clearMap()
            startEndButton.setText("Start Walk")
            startEndButton.setLoading(false)
            isWalkActive = false

            // Show rating bar for feedback
            // TODO: Implement rating bar visibility toggle
        }
    }

    /**
     * Updates the button state based on walk status.
     */
    private fun updateButtonState() {
        startEndButton.setText(if (isWalkActive) "End Walk" else "Start Walk")
    }

    override fun onResume() {
        super.onResume()
        mapViewComponent.onResume()
    }

    override fun onPause() {
        super.onPause()
        mapViewComponent.onPause()
    }

    override fun onDestroy() {
        super.onDestroy()
        mapViewComponent.onDestroy()
    }

    override fun onLowMemory() {
        super.onLowMemory()
        mapViewComponent.onLowMemory()
    }
}