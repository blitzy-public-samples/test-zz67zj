// androidx.compose.material3:material3 version: 1.1.2
// androidx.compose.foundation:foundation version: 1.5.4
// androidx.compose.runtime:runtime version: 1.5.4

package com.dogwalker.app.presentation.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Fill
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.unit.dp
import com.dogwalker.app.presentation.theme.ColorPalette
import com.dogwalker.app.presentation.theme.ShapeTheme
import com.dogwalker.app.presentation.theme.Typography
import kotlin.math.ceil
import kotlin.math.floor

/**
 * Human Tasks:
 * 1. Verify that the star icon dimensions match the design specifications
 * 2. Ensure the touch target area meets accessibility guidelines (48dp minimum)
 * 3. Review color contrast ratios for accessibility compliance
 */

/**
 * A customizable rating bar component that displays interactive star ratings.
 * 
 * Requirement addressed: 8.1.1 Design Specifications
 * - Provides a consistent and interactive rating component
 * - Follows Material Design 3 guidelines for visual styling
 */
@Composable
fun RatingBar(
    modifier: Modifier = Modifier,
    rating: Float = 0f,
    starCount: Int = 5,
    colorPalette: ColorPalette,
    shapeTheme: ShapeTheme,
    typography: Typography,
    onRatingChanged: (Float) -> Unit
) {
    var currentRating by remember { mutableStateOf(rating.coerceIn(0f, starCount.toFloat())) }
    val starSize = 24.dp
    val starSpacing = 4.dp

    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(48.dp) // Ensures minimum touch target size
            .pointerInput(Unit) {
                detectTapGestures { offset ->
                    val starWidth = (size.width - (starSpacing.toPx() * (starCount - 1))) / starCount
                    val touchedStar = (offset.x / (starWidth + starSpacing.toPx())).toInt() + 1
                    currentRating = touchedStar.toFloat().coerceIn(0f, starCount.toFloat())
                    onRatingChanged(currentRating)
                }
            }
    ) {
        Canvas(
            modifier = Modifier.matchParentSize()
        ) {
            val starPath = Path().apply {
                // Create star shape path
                val centerX = starSize.toPx() / 2
                val centerY = starSize.toPx() / 2
                val outerRadius = starSize.toPx() / 2
                val innerRadius = outerRadius * 0.4f
                
                for (i in 0..9) {
                    val radius = if (i % 2 == 0) outerRadius else innerRadius
                    val angle = Math.PI * i / 5 - Math.PI / 2
                    val x = centerX + (radius * kotlin.math.cos(angle)).toFloat()
                    val y = centerY + (radius * kotlin.math.sin(angle)).toFloat()
                    
                    if (i == 0) {
                        moveTo(x, y)
                    } else {
                        lineTo(x, y)
                    }
                }
                close()
            }

            val availableWidth = size.width - (starSpacing.toPx() * (starCount - 1))
            val starWidth = availableWidth / starCount

            for (i in 0 until starCount) {
                val starCenter = Offset(
                    x = i * (starWidth + starSpacing.toPx()) + starWidth / 2,
                    y = size.height / 2
                )

                // Draw empty star
                translate(left = starCenter.x - starWidth / 2) {
                    drawPath(
                        path = starPath,
                        color = colorPalette.onBackground.copy(alpha = 0.2f),
                        style = Fill
                    )
                }

                // Draw filled star based on rating
                if (i < floor(currentRating)) {
                    translate(left = starCenter.x - starWidth / 2) {
                        drawPath(
                            path = starPath,
                            color = colorPalette.primary,
                            style = Fill
                        )
                    }
                } else if (i < ceil(currentRating)) {
                    // Draw partially filled star
                    val fraction = currentRating - floor(currentRating)
                    translate(left = starCenter.x - starWidth / 2) {
                        drawPath(
                            path = starPath,
                            color = colorPalette.primary,
                            style = Fill,
                            alpha = fraction
                        )
                    }
                }
            }
        }
    }
}

/**
 * Draws the rating stars based on the current rating value.
 */
private fun drawRatingStars(
    rating: Float,
    starSize: Size,
    starPath: Path,
    primaryColor: Color,
    onBackgroundColor: Color
) {
    // Implementation moved to the @Composable function above
}

/**
 * Sets the rating value and ensures it's within the valid range.
 */
private fun setRating(
    rating: Float,
    maxRating: Float = 5f,
    onRatingChanged: (Float) -> Unit
) {
    val validatedRating = rating.coerceIn(0f, maxRating)
    onRatingChanged(validatedRating)
}