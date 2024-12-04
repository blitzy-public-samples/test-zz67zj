// androidx.compose.material3:material3 version: 1.1.2
// androidx.compose.ui:ui version: 1.5.4
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Card
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.dogwalker.app.domain.model.Dog
import com.dogwalker.app.presentation.theme.Theme
import com.dogwalker.app.presentation.theme.ColorPalette
import com.dogwalker.app.presentation.theme.ShapeTheme
import com.dogwalker.app.presentation.theme.Typography

/**
 * Human Tasks:
 * 1. Verify that the Material Design 3 theme is properly configured in the app's theme
 * 2. Ensure accessibility contrast ratios meet WCAG 2.1 standards
 * 3. Test component rendering on different screen sizes and orientations
 * 4. Verify proper font loading for typography styles
 */

/**
 * DogCard is a reusable UI component that displays dog details in a card format.
 * 
 * Requirement addressed: 8.1.1 Design Specifications
 * - Implements Material Design 3 guidelines for card components
 * - Provides consistent visual hierarchy for dog information
 * - Uses theme-aware colors and typography
 * 
 * @param dog The Dog data model containing details to be displayed
 */
@Composable
fun DogCard(dog: Dog) {
    // Access theme properties through composition locals
    val colorPalette = Theme.LocalColorPalette.current
    val shapeTheme = Theme.LocalShapeTheme.current
    val typography = Theme.LocalTypography.current

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp),
        shape = MaterialTheme.shapes.medium.copy(
            topStart = shapeTheme.mediumCornerRadius.dp,
            topEnd = shapeTheme.mediumCornerRadius.dp,
            bottomStart = shapeTheme.mediumCornerRadius.dp,
            bottomEnd = shapeTheme.mediumCornerRadius.dp
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            // Dog's name with headline typography
            Text(
                text = dog.name,
                style = MaterialTheme.typography.headlineMedium.copy(
                    fontFamily = typography.getFontFamily(typography.headlineFont),
                    fontWeight = FontWeight.Medium
                ),
                color = colorPalette.onBackground,
                modifier = Modifier.padding(bottom = 8.dp)
            )

            // Dog's breed with body typography
            Text(
                text = dog.breed,
                style = MaterialTheme.typography.bodyLarge.copy(
                    fontFamily = typography.getFontFamily(typography.bodyFont)
                ),
                color = colorPalette.onBackground,
                modifier = Modifier.padding(bottom = 4.dp)
            )

            // Dog's age with body typography
            Text(
                text = "${dog.age} ${if (dog.age == 1) "year" else "years"} old",
                style = MaterialTheme.typography.bodyMedium.copy(
                    fontFamily = typography.getFontFamily(typography.bodyFont)
                ),
                color = colorPalette.onBackground
            )
        }
    }
}