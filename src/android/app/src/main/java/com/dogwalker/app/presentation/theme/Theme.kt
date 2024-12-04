// androidx.compose.material3:material3 version: 1.1.2
// androidx.compose.ui:ui version: 1.5.4
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.staticCompositionLocalOf

/**
 * Human Tasks:
 * 1. Verify that the Material Design 3 theme configuration aligns with the design system specifications
 * 2. Ensure theme colors meet WCAG 2.1 accessibility contrast requirements
 * 3. Test theme appearance in both light and dark modes
 */

/**
 * Theme class encapsulates the overall theme for the Dog Walker application,
 * combining color, shape, and typography styles.
 *
 * Requirement addressed: 8.1.1 Design Specifications
 * - Ensures consistent theming across the Android application
 * - Implements Material Design 3 guidelines
 * - Supports system-based dark/light mode switching
 */
class Theme(
    val colorPalette: ColorPalette,
    val shapeTheme: ShapeTheme,
    val typography: Typography
) {
    companion object {
        /**
         * Local composition providers for theme components
         */
        val LocalColorPalette = staticCompositionLocalOf { ColorPalette() }
        val LocalShapeTheme = staticCompositionLocalOf { ShapeTheme() }
        val LocalTypography = staticCompositionLocalOf { Typography() }
    }
}

/**
 * DogWalkerTheme composable function that applies the application theme
 * to its content.
 *
 * @param darkTheme Boolean flag to determine if dark theme should be used
 * @param content Composable content to be themed
 */
@Composable
fun DogWalkerTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorPalette = if (darkTheme) {
        ColorPalette.darkTheme()
    } else {
        ColorPalette()
    }

    val shapeTheme = ShapeTheme(
        smallCornerRadius = shapeTheme.smallCornerRadius,
        mediumCornerRadius = shapeTheme.mediumCornerRadius
    )

    val typography = Typography(
        headlineFont = typography.headlineFont,
        bodyFont = typography.bodyFont
    )

    val theme = Theme(
        colorPalette = colorPalette,
        shapeTheme = shapeTheme,
        typography = typography
    )

    // Create color scheme for Material Theme
    val colorScheme = if (darkTheme) {
        darkColorScheme(
            primary = colorPalette.primary,
            background = colorPalette.background,
            onBackground = colorPalette.onBackground
        )
    } else {
        lightColorScheme(
            primary = colorPalette.primary,
            background = colorPalette.background,
            onBackground = colorPalette.onBackground
        )
    }

    CompositionLocalProvider(
        Theme.LocalColorPalette provides colorPalette,
        Theme.LocalShapeTheme provides shapeTheme,
        Theme.LocalTypography provides typography
    ) {
        MaterialTheme(
            colorScheme = colorScheme,
            typography = typography.toMaterialTypography(colorPalette),
            content = content
        )
    }
}

/**
 * Extension functions to access theme components from composition
 */
object ThemeUtils {
    val colors: ColorPalette
        @Composable
        get() = Theme.LocalColorPalette.current

    val shapes: ShapeTheme
        @Composable
        get() = Theme.LocalShapeTheme.current

    val typography: Typography
        @Composable
        get() = Theme.LocalTypography.current
}