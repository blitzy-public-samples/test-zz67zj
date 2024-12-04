package com.dogwalker.app.util

import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.util.Log
import androidx.core.app.ActivityCompat // androidx.core:core-ktx:1.6.0
import androidx.core.content.ContextCompat // androidx.core:core-ktx:1.6.0
import com.dogwalker.app.util.Constants.LOCATION_PERMISSION_REQUEST_CODE

/**
 * Human Tasks:
 * 1. Verify that the app's AndroidManifest.xml includes all required permission declarations
 * 2. Ensure proper permission handling is implemented in all Activities that use these utilities
 * 3. Test permission flows on different Android API levels (especially 23 and above)
 */

/**
 * Utility object for handling runtime permissions in the Dog Walker Android application.
 *
 * Requirement addressed: Technical Specification/System Design/8.3 API Design - Permission Management
 * Provides utility functions to handle runtime permissions for accessing location and other sensitive features.
 */
object PermissionUtils {
    private const val TAG = "PermissionUtils"

    /**
     * Checks if a specific permission is granted.
     *
     * @param context The application context
     * @param permission The permission to check (e.g., Manifest.permission.ACCESS_FINE_LOCATION)
     * @return Boolean indicating if the permission is granted (true) or denied (false)
     */
    fun checkPermission(context: Context, permission: String): Boolean {
        return ContextCompat.checkSelfPermission(
            context,
            permission
        ) == PackageManager.PERMISSION_GRANTED
    }

    /**
     * Requests specific permissions from the user.
     *
     * @param activity The activity instance requesting the permissions
     * @param permissions Array of permission strings to request
     */
    fun requestPermission(activity: Activity, permissions: Array<String>) {
        ActivityCompat.requestPermissions(
            activity,
            permissions,
            LOCATION_PERMISSION_REQUEST_CODE
        )
    }

    /**
     * Checks if a specific permission is granted and logs the result for debugging purposes.
     *
     * @param context The application context
     * @param permission The permission to check
     * @return Boolean indicating if the permission is granted (true) or denied (false)
     */
    fun isPermissionGranted(context: Context, permission: String): Boolean {
        val isGranted = checkPermission(context, permission)
        Log.d(TAG, "Permission $permission check result: $isGranted")
        return isGranted
    }

    /**
     * Checks if the app should show permission rationale for a specific permission.
     * This is a helper method to determine if we should show additional explanation to the user.
     *
     * @param activity The activity instance
     * @param permission The permission to check for rationale
     * @return Boolean indicating if rationale should be shown
     */
    fun shouldShowRequestPermissionRationale(activity: Activity, permission: String): Boolean {
        return ActivityCompat.shouldShowRequestPermissionRationale(activity, permission)
    }
}