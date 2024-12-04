// androidx.compose.ui.unit version: 1.5.4
import androidx.compose.ui.unit.dp

/**
 * ShapeTheme class defines the corner radius values for different component sizes
 * in the Dog Walker application following Material Design 3 guidelines.
 * 
 * Requirement addressed: 8.1.1 Design Specifications
 * - Ensures consistent shape styling across the Android application
 * - Provides standardized corner radii for small, medium and large components
 */
data class ShapeTheme(
    // Corner radius for small components like buttons and chips
    val smallCornerRadius: Float = 4.dp.value,
    
    // Corner radius for medium-sized components like cards and dialogs
    val mediumCornerRadius: Float = 8.dp.value,
    
    // Corner radius for large components like bottom sheets and modal dialogs
    val largeCornerRadius: Float = 16.dp.value
) {
    init {
        // Validate that corner radii are non-negative
        require(smallCornerRadius >= 0f) { "Small corner radius must be non-negative" }
        require(mediumCornerRadius >= 0f) { "Medium corner radius must be non-negative" }
        require(largeCornerRadius >= 0f) { "Large corner radius must be non-negative" }
        
        // Validate that corner radii follow a logical progression
        require(smallCornerRadius <= mediumCornerRadius) { "Small corner radius should not exceed medium corner radius" }
        require(mediumCornerRadius <= largeCornerRadius) { "Medium corner radius should not exceed large corner radius" }
    }
}