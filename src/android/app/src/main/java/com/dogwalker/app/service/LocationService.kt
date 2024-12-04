package com.dogwalker.app.service

import android.content.Context
import android.location.Location
import android.os.Looper
import android.util.Log
import com.google.android.gms.location.FusedLocationProviderClient // com.google.android.gms.location:20.0.0
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import com.dogwalker.app.util.LocationUtils
import com.dogwalker.app.domain.model.Location as DogWalkerLocation
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import java.util.UUID

/**
 * Human Tasks:
 * 1. Verify that Google Play Services is properly configured in the project
 * 2. Ensure the app's AndroidManifest.xml includes both ACCESS_FINE_LOCATION and ACCESS_COARSE_LOCATION permissions
 * 3. Test location tracking on different Android versions and devices
 * 4. Configure location update intervals based on battery optimization requirements
 * 5. Verify that location tracking stops properly when the app is terminated
 */

/**
 * Service class that handles live GPS tracking and location updates for the Dog Walker application.
 *
 * Requirement addressed: Service Execution (1.3 Scope/Core Features/Service Execution)
 * Supports live GPS tracking and route recording for dog walking services.
 */
class LocationService(private val context: Context) {
    private val TAG = "LocationService"
    
    // FusedLocationProviderClient for efficient location tracking
    private val fusedLocationClient: FusedLocationProviderClient = 
        LocationServices.getFusedLocationProviderClient(context)
    
    // Coroutine scope for handling asynchronous operations
    private val serviceScope = CoroutineScope(Dispatchers.IO + Job())
    
    // Location request configuration
    private val locationRequest = LocationRequest.Builder(
        Priority.PRIORITY_HIGH_ACCURACY,
        UPDATE_INTERVAL_MS
    ).apply {
        setMinUpdateIntervalMillis(FASTEST_UPDATE_INTERVAL_MS)
        setMaxUpdateDelayMillis(MAX_UPDATE_DELAY_MS)
    }.build()
    
    // Location callback for handling location updates
    private var locationCallback: LocationCallback? = null
    
    // Track if location updates are active
    private var isTrackingActive = false
    
    /**
     * Starts live GPS tracking and updates the backend with the user's location.
     *
     * Requirement addressed: Service Execution (1.3 Scope/Core Features/Service Execution)
     * Implements real-time location tracking for active dog walks.
     *
     * @param walkId The ID of the active walk session
     * @return Boolean indicating if location updates were successfully started
     */
    fun startLocationUpdates(walkId: String): Boolean {
        if (isTrackingActive) {
            Log.w(TAG, "Location updates already active")
            return false
        }

        if (!LocationUtils.isLocationPermissionGranted(context)) {
            Log.e(TAG, "Location permissions not granted")
            return false
        }

        try {
            locationCallback = object : LocationCallback() {
                override fun onLocationResult(locationResult: LocationResult) {
                    locationResult.lastLocation?.let { location ->
                        handleLocationUpdate(location, walkId)
                    }
                }
            }

            fusedLocationClient.requestLocationUpdates(
                locationRequest,
                locationCallback!!,
                Looper.getMainLooper()
            ).addOnSuccessListener {
                isTrackingActive = true
                Log.d(TAG, "Location updates started successfully for walk: $walkId")
            }.addOnFailureListener { exception ->
                Log.e(TAG, "Failed to start location updates", exception)
                locationCallback = null
            }

            return true
        } catch (e: Exception) {
            Log.e(TAG, "Error starting location updates", e)
            return false
        }
    }

    /**
     * Stops live GPS tracking and releases resources.
     *
     * @return Boolean indicating if location updates were successfully stopped
     */
    fun stopLocationUpdates(): Boolean {
        return try {
            locationCallback?.let {
                fusedLocationClient.removeLocationUpdates(it)
                locationCallback = null
                isTrackingActive = false
                Log.d(TAG, "Location updates stopped successfully")
                true
            } ?: false
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping location updates", e)
            false
        }
    }

    /**
     * Fetches the last known location of the device.
     *
     * @return Location? The last known location or null if unavailable
     */
    suspend fun getLastKnownLocation(): DogWalkerLocation? {
        if (!LocationUtils.isLocationPermissionGranted(context)) {
            Log.e(TAG, "Location permissions not granted")
            return null
        }

        return try {
            val location = LocationUtils.getCurrentLocation(context)
            location?.let { 
                DogWalkerLocation(
                    id = UUID.randomUUID().toString(),
                    latitude = it.latitude,
                    longitude = it.longitude,
                    userId = "", // To be set by the caller
                    walkId = "", // To be set by the caller
                    timestamp = System.currentTimeMillis()
                )
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error getting last known location", e)
            null
        }
    }

    /**
     * Handles incoming location updates and processes them for the active walk.
     *
     * @param location The new location update
     * @param walkId The ID of the active walk
     */
    private fun handleLocationUpdate(location: Location, walkId: String) {
        serviceScope.launch {
            try {
                val dogWalkerLocation = DogWalkerLocation(
                    id = UUID.randomUUID().toString(),
                    latitude = location.latitude,
                    longitude = location.longitude,
                    userId = "", // To be set by the caller
                    walkId = walkId,
                    timestamp = System.currentTimeMillis()
                )
                
                // TODO: Send location update to backend or save locally
                Log.d(TAG, "Location update processed: ${dogWalkerLocation.toFormattedString()}")
            } catch (e: Exception) {
                Log.e(TAG, "Error processing location update", e)
            }
        }
    }

    companion object {
        // Location update intervals
        private const val UPDATE_INTERVAL_MS = 10000L // 10 seconds
        private const val FASTEST_UPDATE_INTERVAL_MS = 5000L // 5 seconds
        private const val MAX_UPDATE_DELAY_MS = 15000L // 15 seconds
    }
}