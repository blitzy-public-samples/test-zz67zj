// androidx.compose.material3:material3 version: 1.1.2
// androidx.compose.runtime version: 1.5.4
// androidx.compose.foundation version: 1.5.4
// androidx.compose.ui version: 1.5.4
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.dp
import com.dogwalker.app.presentation.theme.ColorPalette
import com.dogwalker.app.presentation.theme.ShapeTheme
import com.dogwalker.app.presentation.theme.Typography

/**
 * Human Tasks:
 * 1. Verify that the Material Design 3 dependency is properly added to the project's build.gradle
 * 2. Ensure the app theme is correctly set up to use Material Design 3 components
 * 3. Test the button's accessibility with TalkBack enabled
 * 4. Verify button states (enabled, disabled, loading) meet design requirements
 */

/**
 * A custom button component with integrated loading spinner functionality.
 * 
 * Requirement addressed: 8.1.1 Design Specifications
 * - Ensures consistent button styling across the Android application
 * - Implements Material Design 3 guidelines for buttons
 * - Maintains minimum touch target size of 44dp for accessibility
 * - Provides clear visual feedback during loading states
 */
@Composable
class LoadingButton {
    // Button state properties
    private var isLoading by remember { mutableStateOf(false) }
    private var buttonText by remember { mutableStateOf("") }
    
    // Button style properties
    private val buttonHeight = 48.dp
    private val loadingIndicatorSize = 24.dp
    private val buttonMinWidth = 120.dp
    
    /**
     * Creates a new LoadingButton instance
     * 
     * @param buttonText Initial text to display on the button
     * @param isLoading Initial loading state of the button
     */
    constructor(
        buttonText: String,
        isLoading: Boolean = false
    ) {
        this.buttonText = buttonText
        this.isLoading = isLoading
    }
    
    /**
     * Updates the loading state of the button
     * 
     * @param isLoading New loading state
     */
    fun setLoading(isLoading: Boolean) {
        this.isLoading = isLoading
    }
    
    /**
     * Updates the text displayed on the button
     * 
     * @param text New text to display
     */
    fun setText(text: String) {
        this.buttonText = text
    }
    
    /**
     * The composable function that renders the button
     * 
     * @param onClick Callback function to execute when the button is clicked
     * @param modifier Optional modifier for customizing the button's layout
     * @param enabled Whether the button is enabled or disabled
     */
    @Composable
    fun Content(
        onClick: () -> Unit,
        modifier: Modifier = Modifier,
        enabled: Boolean = true
    ) {
        Button(
            onClick = {
                if (!isLoading && enabled) {
                    onClick()
                }
            },
            modifier = modifier
                .size(width = buttonMinWidth, height = buttonHeight),
            enabled = enabled && !isLoading,
            shape = androidx.compose.foundation.shape.RoundedCornerShape(ShapeTheme().mediumCornerRadius),
            colors = androidx.compose.material3.ButtonDefaults.buttonColors(
                containerColor = ColorPalette().primary,
                contentColor = ColorPalette().onPrimary,
                disabledContainerColor = ColorPalette().primary.copy(alpha = 0.5f),
                disabledContentColor = ColorPalette().onPrimary.copy(alpha = 0.5f)
            )
        ) {
            Box(
                contentAlignment = Alignment.Center
            ) {
                if (isLoading) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(loadingIndicatorSize),
                        color = ColorPalette().onPrimary,
                        strokeWidth = 2.dp
                    )
                } else {
                    Text(
                        text = buttonText,
                        style = TextStyle(
                            fontFamily = androidx.compose.ui.text.font.FontFamily.Default,
                            fontSize = androidx.compose.ui.unit.sp(Typography().bodySize),
                            color = ColorPalette().onPrimary
                        )
                    )
                }
            }
        }
    }
}