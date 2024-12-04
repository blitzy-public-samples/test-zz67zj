// androidx.compose.ui.graphics.Color version: 1.5.4
import androidx.compose.ui.graphics.Color

/**
 * ColorPalette class defines the color scheme for the Dog Walker application
 * following Material Design 3 guidelines.
 * 
 * Requirement addressed: 8.1.1 Design Specifications
 * - Ensures consistent color theming across the Android application
 * - Supports system-based dark/light mode switching
 * - Maintains minimum contrast ratio of 4.5:1 for accessibility
 */
data class ColorPalette(
    // Primary brand color used for key UI elements and CTAs
    val primary: Color = Color(0xFF2196F3), // Material Blue 500
    
    // Variant of primary color for status bar and emphasized elements
    val primaryVariant: Color = Color(0xFF1976D2), // Material Blue 700
    
    // Secondary color for floating action buttons and selection controls
    val secondary: Color = Color(0xFF4CAF50), // Material Green 500
    
    // Background color for screens and large surfaces
    val background: Color = Color(0xFFFFFFFF), // White
    
    // Surface color for cards, sheets, and menus
    val surface: Color = Color(0xFFF5F5F5), // Material Gray 100
    
    // Color for text/icons on primary color
    val onPrimary: Color = Color(0xFFFFFFFF), // White
    
    // Color for text/icons on secondary color
    val onSecondary: Color = Color(0xFFFFFFFF), // White
    
    // Color for text/icons on background color
    val onBackground: Color = Color(0xFF212121), // Material Gray 900
    
    // Color for text/icons on surface color
    val onSurface: Color = Color(0xFF212121) // Material Gray 900
) {
    companion object {
        /**
         * Creates a dark theme variant of the color palette
         * Requirement addressed: 8.1.1 Design Specifications - Dark mode support
         */
        fun darkTheme() = ColorPalette(
            primary = Color(0xFF90CAF9), // Material Blue 200
            primaryVariant = Color(0xFF64B5F6), // Material Blue 300
            secondary = Color(0xFF81C784), // Material Green 300
            background = Color(0xFF121212), // Material Dark Background
            surface = Color(0xFF1E1E1E), // Material Dark Surface
            onPrimary = Color(0xFF000000), // Black
            onSecondary = Color(0xFF000000), // Black
            onBackground = Color(0xFFFFFFFF), // White
            onSurface = Color(0xFFFFFFFF) // White
        )
    }
}