package com.dogwalker.app.util

import android.Manifest
import android.content.Context
import android.location.Location
import android.util.Log
import com.google.android.gms.location.FusedLocationProviderClient // com.google.android.gms.location:20.0.0
import com.google.android.gms.location.LocationServices
import com.google.android.gms.tasks.Task
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine
import com.dogwalker.app.util.Constants.LOCATION_PERMISSION_REQUEST_CODE
import com.dogwalker.app.util.PermissionUtils.checkPermission
import com.dogwalker.app.util.PermissionUtils.isPermissionGranted

/**
 * Human Tasks:
 * 1. Verify that Google Play Services is properly configured in the project
 * 2. Ensure the app's AndroidManifest.xml includes both ACCESS_FINE_LOCATION and ACCESS_COARSE_LOCATION permissions
 * 3. Test location fetching on different Android versions and devices
 * 4. Verify location accuracy settings meet the app's requirements
 */

/**
 * Utility object for handling location-related operations in the Dog Walker application.
 *
 * Requirement addressed: Service Execution (1.3 Scope/Core Features/Service Execution)
 * Supports live GPS tracking and location validation for dog walking services.
 */
object LocationUtils {
    private const val TAG = "LocationUtils"

    /**
     * Checks if location permissions are granted for the application.
     *
     * @param context The application context
     * @return Boolean indicating if location permissions are granted
     */
    fun isLocationPermissionGranted(context: Context): Boolean {
        return isPermissionGranted(context, Manifest.permission.ACCESS_FINE_LOCATION) &&
                isPermissionGranted(context, Manifest.permission.ACCESS_COARSE_LOCATION)
    }

    /**
     * Fetches the current location of the device using FusedLocationProviderClient.
     * Returns null if permissions are not granted or location cannot be retrieved.
     *
     * Requirement addressed: Service Execution (1.3 Scope/Core Features/Service Execution)
     * Provides real-time location data for tracking dog walking services.
     *
     * @param context The application context
     * @return Location? The current device location or null if unavailable
     */
    suspend fun getCurrentLocation(context: Context): Location? = suspendCoroutine { continuation ->
        try {
            if (!isLocationPermissionGranted(context)) {
                Log.e(TAG, "Location permissions not granted")
                continuation.resume(null)
                return@suspendCoroutine
            }

            val fusedLocationClient: FusedLocationProviderClient = 
                LocationServices.getFusedLocationProviderClient(context)

            fusedLocationClient.lastLocation
                .addOnSuccessListener { location ->
                    if (location != null) {
                        Log.d(TAG, "Location retrieved: lat=${location.latitude}, lng=${location.longitude}")
                        continuation.resume(location)
                    } else {
                        Log.w(TAG, "Location is null")
                        continuation.resume(null)
                    }
                }
                .addOnFailureListener { exception ->
                    Log.e(TAG, "Error getting location", exception)
                    continuation.resumeWithException(exception)
                }
        } catch (e: Exception) {
            Log.e(TAG, "Error in getCurrentLocation", e)
            continuation.resumeWithException(e)
        }
    }

    /**
     * Extension function to handle location task results asynchronously.
     * 
     * @param onSuccess Callback for successful location retrieval
     * @param onFailure Callback for location retrieval failure
     */
    private fun Task<Location>.addLocationListeners(
        onSuccess: (Location?) -> Unit,
        onFailure: (Exception) -> Unit
    ) {
        this.addOnSuccessListener { location ->
            onSuccess(location)
        }.addOnFailureListener { exception ->
            onFailure(exception)
        }
    }
}