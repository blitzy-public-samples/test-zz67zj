// androidx.compose.runtime version: 1.5.4
// com.google.android.gms.maps version: 20.0.0
import android.content.Context
import android.location.Location
import android.util.Log
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.remember
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.MapView
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.MarkerOptions
import com.google.android.gms.maps.model.PolylineOptions
import com.dogwalker.app.util.LocationUtils
import com.dogwalker.app.presentation.theme.Theme
import com.dogwalker.app.service.LocationService

/**
 * Human Tasks:
 * 1. Verify that Google Maps API key is properly configured in AndroidManifest.xml
 * 2. Ensure the project has the required Google Play Services dependencies
 * 3. Test map functionality on different Android versions and screen sizes
 * 4. Verify that location permissions are properly handled in the app
 * 5. Configure map styling to match the app's theme requirements
 */

/**
 * MapViewComponent class that encapsulates the map functionality for the Dog Walker application.
 * 
 * Requirement addressed: Service Execution (1.3 Scope/Core Features/Service Execution)
 * Implements map display and interaction capabilities for dog walking route visualization.
 */
class MapViewComponent(private val context: Context) {
    private val TAG = "MapViewComponent"
    private var mapView: MapView? = null
    private var googleMap: GoogleMap? = null
    private val locationService = LocationService(context)

    /**
     * Initializes the MapView with required configurations.
     * 
     * Requirement addressed: Service Execution (1.3 Scope/Core Features/Service Execution)
     * Sets up the map interface for route tracking and visualization.
     * 
     * @param context The application context
     * @return Boolean indicating if initialization was successful
     */
    fun initializeMap(context: Context): Boolean {
        return try {
            if (!LocationUtils.isLocationPermissionGranted(context)) {
                Log.e(TAG, "Location permissions not granted")
                return false
            }

            mapView = MapView(context).apply {
                onCreate(null)
                getMapAsync { map ->
                    googleMap = map
                    setupMapSettings(map)
                }
            }

            true
        } catch (e: Exception) {
            Log.e(TAG, "Error initializing map", e)
            false
        }
    }

    /**
     * Updates the user's location on the map.
     * 
     * @param location The new location to display
     * @return Boolean indicating if the update was successful
     */
    fun updateUserLocation(location: Location): Boolean {
        return try {
            val latLng = LatLng(location.latitude, location.longitude)
            googleMap?.let { map ->
                map.animateCamera(CameraUpdateFactory.newLatLngZoom(latLng, DEFAULT_ZOOM))
                map.addMarker(
                    MarkerOptions()
                        .position(latLng)
                        .title("Current Location")
                )
                true
            } ?: false
        } catch (e: Exception) {
            Log.e(TAG, "Error updating user location", e)
            false
        }
    }

    /**
     * Clears all markers and overlays from the map.
     * 
     * @return Boolean indicating if the clear operation was successful
     */
    fun clearMap(): Boolean {
        return try {
            googleMap?.let { map ->
                map.clear()
                map.moveCamera(CameraUpdateFactory.zoomTo(DEFAULT_ZOOM))
                true
            } ?: false
        } catch (e: Exception) {
            Log.e(TAG, "Error clearing map", e)
            false
        }
    }

    /**
     * Sets up the map's UI settings and configurations.
     * 
     * @param map The GoogleMap instance to configure
     */
    private fun setupMapSettings(map: GoogleMap) {
        map.apply {
            uiSettings.apply {
                isZoomControlsEnabled = true
                isCompassEnabled = true
                isMyLocationButtonEnabled = true
                isMapToolbarEnabled = true
            }
            isMyLocationEnabled = LocationUtils.isLocationPermissionGranted(context)
            mapType = GoogleMap.MAP_TYPE_NORMAL
        }
    }

    /**
     * Lifecycle methods to properly manage the MapView component
     */
    fun onStart() {
        mapView?.onStart()
    }

    fun onResume() {
        mapView?.onResume()
    }

    fun onPause() {
        mapView?.onPause()
    }

    fun onStop() {
        mapView?.onStop()
    }

    fun onDestroy() {
        mapView?.onDestroy()
    }

    fun onLowMemory() {
        mapView?.onLowMemory()
    }

    companion object {
        private const val DEFAULT_ZOOM = 15f
        private const val MIN_ZOOM = 10f
        private const val MAX_ZOOM = 20f
    }
}

/**
 * Composable function that wraps the MapViewComponent for use in Jetpack Compose UI.
 * 
 * Requirement addressed: Service Execution (1.3 Scope/Core Features/Service Execution)
 * Provides a composable map interface for the application.
 * 
 * @param context The application context
 * @param onMapReady Callback for when the map is ready
 */
@Composable
fun DogWalkerMap(
    context: Context,
    onMapReady: (MapViewComponent) -> Unit
) {
    val mapComponent = remember { MapViewComponent(context) }

    DisposableEffect(Unit) {
        mapComponent.initializeMap(context)
        mapComponent.onStart()
        mapComponent.onResume()
        onMapReady(mapComponent)

        onDispose {
            mapComponent.onPause()
            mapComponent.onStop()
            mapComponent.onDestroy()
        }
    }
}