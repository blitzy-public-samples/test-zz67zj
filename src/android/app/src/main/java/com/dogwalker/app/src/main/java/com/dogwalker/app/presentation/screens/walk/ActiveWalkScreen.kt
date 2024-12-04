// androidx.compose.ui:ui:1.5.0
import androidx.compose.foundation.layout.*
import androidx.compose.material.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

// androidx.lifecycle:lifecycle-viewmodel-ktx:2.6.1
import androidx.lifecycle.LiveData
import androidx.lifecycle.Observer

// kotlinx.coroutines:coroutines-android:1.6.4
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

// Google Maps Compose - version: 2.11.4
import com.google.android.gms.maps.compose.GoogleMap
import com.google.android.gms.maps.compose.Marker
import com.google.android.gms.maps.compose.rememberCameraPositionState

// Internal imports
import com.dogwalker.app.presentation.screens.walk.ActiveWalkViewModel
import com.dogwalker.app.domain.model.Walk
import com.dogwalker.app.domain.model.Location

/**
 * Human Tasks:
 * 1. Configure Google Maps API key in the AndroidManifest.xml file
 * 2. Ensure location permissions are properly requested before accessing GPS
 * 3. Verify that the minimum SDK version supports all Compose features used
 * 4. Test the screen's behavior with different network conditions
 * 5. Verify proper error handling for GPS signal loss scenarios
 */

/**
 * Composable screen that displays the active walk interface with live GPS tracking.
 *
 * Requirements addressed:
 * - Service Execution (1.3 Scope/Core Features/Service Execution)
 *   Implements live GPS tracking, walk initiation, and walk completion functionalities
 * - User Interface Design (8.1.1 Design Specifications)
 *   Ensures consistent and responsive UI for the Active Walk screen
 */
@Composable
fun ActiveWalkScreen(
    viewModel: ActiveWalkViewModel,
    modifier: Modifier = Modifier
) {
    // State management for walk data
    var currentWalk by remember { mutableStateOf<Walk?>(null) }
    var walkRoute by remember { mutableStateOf<List<Location>>(emptyList()) }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    
    // Observe walk data changes
    DisposableEffect(viewModel) {
        val walkObserver = Observer<Walk> { walk ->
            currentWalk = walk
        }
        
        val routeObserver = Observer<List<Location>> { route ->
            walkRoute = route
        }
        
        val errorObserver = Observer<String> { error ->
            errorMessage = error
        }
        
        viewModel.currentWalk.observeForever(walkObserver)
        viewModel.walkRoute.observeForever(routeObserver)
        viewModel.errorState.observeForever(errorObserver)
        
        onDispose {
            viewModel.currentWalk.removeObserver(walkObserver)
            viewModel.walkRoute.removeObserver(routeObserver)
            viewModel.errorState.removeObserver(errorObserver)
        }
    }

    Column(
        modifier = modifier.fillMaxSize(),
        verticalArrangement = Arrangement.SpaceBetween
    ) {
        // Map view for displaying the walk route
        Box(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
        ) {
            GoogleMap(
                modifier = Modifier.fillMaxSize(),
                cameraPositionState = rememberCameraPositionState()
            ) {
                // Display route markers
                walkRoute.forEach { location ->
                    Marker(
                        position = com.google.android.gms.maps.model.LatLng(
                            location.latitude,
                            location.longitude
                        )
                    )
                }
            }
        }

        // Walk information and controls
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            elevation = 8.dp
        ) {
            Column(
                modifier = Modifier.padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // Walk duration
                currentWalk?.let { walk ->
                    Text(
                        text = "Duration: ${walk.calculateDuration()}",
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold
                    )
                }

                // Distance covered
                if (walkRoute.isNotEmpty()) {
                    Text(
                        text = "Distance: ${calculateDistance(walkRoute)} km",
                        fontSize = 18.sp
                    )
                }

                // Error messages
                errorMessage?.let { error ->
                    Text(
                        text = error,
                        color = Color.Red,
                        fontSize = 14.sp
                    )
                }

                // Control buttons
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceEvenly
                ) {
                    if (currentWalk == null) {
                        Button(
                            onClick = {
                                startWalk(viewModel)
                            }
                        ) {
                            Text("Start Walk")
                        }
                    } else {
                        Button(
                            onClick = {
                                endWalk(viewModel, currentWalk?.id)
                            }
                        ) {
                            Text("End Walk")
                        }
                    }
                }
            }
        }
    }
}

/**
 * Initiates a new walk session.
 *
 * Requirements addressed:
 * - Service Execution (1.3)
 *   Handles walk initiation with proper error handling
 */
private fun startWalk(viewModel: ActiveWalkViewModel) {
    CoroutineScope(Dispatchers.Main).launch {
        try {
            // TODO: Get these values from the booking context
            viewModel.startWalk(
                userId = "current_user_id",
                dogId = "current_dog_id",
                bookingId = "current_booking_id",
                initialLocation = Location(
                    id = "initial_location",
                    latitude = 0.0, // Get from current GPS
                    longitude = 0.0, // Get from current GPS
                    userId = "current_user_id",
                    walkId = "pending",
                    timestamp = System.currentTimeMillis()
                )
            )
        } catch (e: Exception) {
            // Error handling is managed by ViewModel
        }
    }
}

/**
 * Ends the current walk session.
 *
 * Requirements addressed:
 * - Service Execution (1.3)
 *   Handles walk completion with proper error handling
 */
private fun endWalk(viewModel: ActiveWalkViewModel, walkId: String?) {
    if (walkId == null) return
    
    CoroutineScope(Dispatchers.Main).launch {
        try {
            viewModel.endWalk(
                walkId = walkId,
                endTime = java.time.Instant.now().toString()
            )
        } catch (e: Exception) {
            // Error handling is managed by ViewModel
        }
    }
}

/**
 * Calculates the total distance covered during the walk.
 *
 * @param route List of location points in the walk route
 * @return Total distance in kilometers
 */
private fun calculateDistance(route: List<Location>): Double {
    var totalDistance = 0.0
    for (i in 0 until route.size - 1) {
        val loc1 = route[i]
        val loc2 = route[i + 1]
        totalDistance += calculateHaversineDistance(
            loc1.latitude, loc1.longitude,
            loc2.latitude, loc2.longitude
        )
    }
    return totalDistance
}

/**
 * Calculates the distance between two points using the Haversine formula.
 *
 * @return Distance in kilometers
 */
private fun calculateHaversineDistance(
    lat1: Double, lon1: Double,
    lat2: Double, lon2: Double
): Double {
    val R = 6371.0 // Earth's radius in kilometers
    
    val dLat = Math.toRadians(lat2 - lat1)
    val dLon = Math.toRadians(lon2 - lon1)
    
    val a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
            Math.sin(dLon / 2) * Math.sin(dLon / 2)
    
    val c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    
    return R * c
}