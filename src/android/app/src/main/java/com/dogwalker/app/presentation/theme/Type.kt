// androidx.compose.material3:material3 version: 1.1.2
// androidx.compose.ui:ui version: 1.5.4
import androidx.compose.material3.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import com.dogwalker.app.presentation.theme.ColorPalette

/**
 * Human Tasks:
 * 1. Verify that the specified font families (Roboto, Inter) are included in the project's assets
 * 2. Ensure font licenses are properly documented and included in the project
 * 3. Review typography scale values match the design system specifications
 */

/**
 * Typography class defines the text styles for the Dog Walker application
 * following Material Design 3 guidelines.
 * 
 * Requirement addressed: 8.1.1 Design Specifications
 * - Ensures consistent typography styling across the Android application
 * - Implements Material Design 3 type scale
 * - Maintains readable font sizes for accessibility
 */
data class Typography(
    val headlineFont: String = "Roboto",
    val bodyFont: String = "Inter",
    val captionFont: String = "Inter",
    val headlineSize: Int = 24,
    val bodySize: Int = 16,
    val captionSize: Int = 12,
    val headlineWeight: String = "Medium",
    val bodyWeight: String = "Normal",
    val captionWeight: String = "Light"
) {
    /**
     * Converts the typography configuration into Material3 Typography instance
     * with proper TextStyle definitions for each text category
     */
    fun toMaterialTypography(colorPalette: ColorPalette) = Typography(
        displayLarge = TextStyle(
            fontFamily = FontFamily.Default,
            fontWeight = FontWeight.Light,
            fontSize = 57.sp,
            lineHeight = 64.sp,
            letterSpacing = 0.sp,
            color = colorPalette.onBackground
        ),
        displayMedium = TextStyle(
            fontFamily = FontFamily.Default,
            fontWeight = FontWeight.Light,
            fontSize = 45.sp,
            lineHeight = 52.sp,
            letterSpacing = 0.sp,
            color = colorPalette.onBackground
        ),
        displaySmall = TextStyle(
            fontFamily = FontFamily.Default,
            fontWeight = FontWeight.Normal,
            fontSize = 36.sp,
            lineHeight = 44.sp,
            letterSpacing = 0.sp,
            color = colorPalette.onBackground
        ),
        headlineLarge = TextStyle(
            fontFamily = getFontFamily(headlineFont),
            fontWeight = getFontWeight(headlineWeight),
            fontSize = headlineSize.sp,
            lineHeight = (headlineSize * 1.2).sp,
            letterSpacing = 0.sp,
            color = colorPalette.onBackground
        ),
        headlineMedium = TextStyle(
            fontFamily = getFontFamily(headlineFont),
            fontWeight = getFontWeight(headlineWeight),
            fontSize = (headlineSize - 4).sp,
            lineHeight = ((headlineSize - 4) * 1.2).sp,
            letterSpacing = 0.15.sp,
            color = colorPalette.onBackground
        ),
        headlineSmall = TextStyle(
            fontFamily = getFontFamily(headlineFont),
            fontWeight = getFontWeight(headlineWeight),
            fontSize = (headlineSize - 8).sp,
            lineHeight = ((headlineSize - 8) * 1.2).sp,
            letterSpacing = 0.15.sp,
            color = colorPalette.onBackground
        ),
        titleLarge = TextStyle(
            fontFamily = getFontFamily(bodyFont),
            fontWeight = FontWeight.Medium,
            fontSize = 22.sp,
            lineHeight = 28.sp,
            letterSpacing = 0.sp,
            color = colorPalette.onBackground
        ),
        titleMedium = TextStyle(
            fontFamily = getFontFamily(bodyFont),
            fontWeight = getFontWeight(bodyWeight),
            fontSize = bodySize.sp,
            lineHeight = (bodySize * 1.5).sp,
            letterSpacing = 0.15.sp,
            color = colorPalette.onBackground
        ),
        titleSmall = TextStyle(
            fontFamily = getFontFamily(bodyFont),
            fontWeight = getFontWeight(bodyWeight),
            fontSize = (bodySize - 2).sp,
            lineHeight = ((bodySize - 2) * 1.5).sp,
            letterSpacing = 0.1.sp,
            color = colorPalette.onBackground
        ),
        bodyLarge = TextStyle(
            fontFamily = getFontFamily(bodyFont),
            fontWeight = getFontWeight(bodyWeight),
            fontSize = bodySize.sp,
            lineHeight = (bodySize * 1.5).sp,
            letterSpacing = 0.5.sp,
            color = colorPalette.onBackground
        ),
        bodyMedium = TextStyle(
            fontFamily = getFontFamily(bodyFont),
            fontWeight = getFontWeight(bodyWeight),
            fontSize = (bodySize - 2).sp,
            lineHeight = ((bodySize - 2) * 1.5).sp,
            letterSpacing = 0.25.sp,
            color = colorPalette.onBackground
        ),
        bodySmall = TextStyle(
            fontFamily = getFontFamily(bodyFont),
            fontWeight = getFontWeight(bodyWeight),
            fontSize = (bodySize - 4).sp,
            lineHeight = ((bodySize - 4) * 1.5).sp,
            letterSpacing = 0.4.sp,
            color = colorPalette.onBackground
        ),
        labelLarge = TextStyle(
            fontFamily = getFontFamily(captionFont),
            fontWeight = getFontWeight(captionWeight),
            fontSize = (captionSize + 2).sp,
            lineHeight = ((captionSize + 2) * 1.5).sp,
            letterSpacing = 0.1.sp,
            color = colorPalette.onBackground
        ),
        labelMedium = TextStyle(
            fontFamily = getFontFamily(captionFont),
            fontWeight = getFontWeight(captionWeight),
            fontSize = captionSize.sp,
            lineHeight = (captionSize * 1.5).sp,
            letterSpacing = 0.5.sp,
            color = colorPalette.onBackground
        ),
        labelSmall = TextStyle(
            fontFamily = getFontFamily(captionFont),
            fontWeight = getFontWeight(captionWeight),
            fontSize = (captionSize - 2).sp,
            lineHeight = ((captionSize - 2) * 1.5).sp,
            letterSpacing = 0.5.sp,
            color = colorPalette.onBackground
        )
    )

    private fun getFontFamily(fontName: String): FontFamily {
        return when (fontName.lowercase()) {
            "roboto" -> FontFamily.Default
            "inter" -> FontFamily.Default // Replace with actual Inter font family when added to project
            else -> FontFamily.Default
        }
    }

    private fun getFontWeight(weight: String): FontWeight {
        return when (weight.lowercase()) {
            "light" -> FontWeight.Light
            "normal" -> FontWeight.Normal
            "medium" -> FontWeight.Medium
            "bold" -> FontWeight.Bold
            else -> FontWeight.Normal
        }
    }
}