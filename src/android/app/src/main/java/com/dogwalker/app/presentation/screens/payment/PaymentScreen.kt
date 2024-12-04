/**
 * Human Tasks:
 * 1. Verify accessibility features are properly implemented for payment interactions
 * 2. Test payment flow with different payment methods and amounts
 * 3. Ensure proper error handling and user feedback for payment failures
 * 4. Review payment-related analytics tracking implementation
 */

package com.dogwalker.app.presentation.screens.payment

// External imports
import androidx.compose.foundation.layout.* // version: 1.5.0
import androidx.compose.material3.* // version: 1.1.2
import androidx.compose.runtime.* // version: 1.5.0
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp

// Internal imports
import com.dogwalker.app.presentation.components.PaymentCard
import com.dogwalker.app.presentation.theme.Theme
import com.dogwalker.app.domain.model.Payment

/**
 * PaymentScreen composable that displays payment details and processing UI.
 *
 * Requirements addressed:
 * - Payments (1.3 Scope/Core Features/Payments)
 *   Implements the payment processing interface with secure payment handling
 *   and automated billing functionality.
 * - User Interface Design (8.1 User Interface Design/8.1.1 Design Specifications)
 *   Ensures a consistent and accessible UI for payment-related interactions
 *   following Material Design 3 guidelines.
 *
 * @param viewModel The ViewModel handling payment processing logic
 */
@Composable
fun PaymentScreen(
    viewModel: PaymentViewModel,
    modifier: Modifier = Modifier
) {
    val colorPalette = Theme.LocalColorPalette.current
    val typography = Theme.LocalTypography.current
    
    // Observe payment-related states
    val paymentStatus by viewModel.paymentStatus.collectAsState()
    val isProcessing by viewModel.isProcessing.collectAsState()
    val error by viewModel.error.collectAsState()

    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Payment Header
        Text(
            text = "Payment Details",
            style = typography.toMaterialTypography(colorPalette).headlineMedium,
            color = colorPalette.onBackground
        )

        // Payment Card
        PaymentCard(
            payment = Payment(
                id = "payment_id",
                amount = 29.99,
                method = Payment.METHOD_CREDIT_CARD,
                status = if (isProcessing) Payment.STATUS_PROCESSING else paymentStatus,
                timestamp = System.currentTimeMillis()
            )
        )

        // Error Message
        error?.let { errorMessage ->
            Text(
                text = errorMessage,
                style = typography.toMaterialTypography(colorPalette).bodyMedium,
                color = colorPalette.onBackground
            )
        }

        // Process Payment Button
        Button(
            onClick = {
                viewModel.processPayment(
                    Payment(
                        id = "payment_id",
                        amount = 29.99,
                        method = Payment.METHOD_CREDIT_CARD,
                        status = Payment.STATUS_PENDING,
                        timestamp = System.currentTimeMillis()
                    )
                )
            },
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp),
            enabled = !isProcessing,
            colors = ButtonDefaults.buttonColors(
                containerColor = colorPalette.primary,
                contentColor = colorPalette.onPrimary
            )
        ) {
            if (isProcessing) {
                CircularProgressIndicator(
                    modifier = Modifier.size(24.dp),
                    color = colorPalette.onPrimary
                )
            } else {
                Text(
                    text = "Process Payment",
                    style = typography.toMaterialTypography(colorPalette).bodyLarge
                )
            }
        }

        // Payment Status
        when (paymentStatus) {
            Payment.STATUS_COMPLETED -> {
                Text(
                    text = "Payment Successful",
                    style = typography.toMaterialTypography(colorPalette).bodyLarge,
                    color = colorPalette.secondary
                )
            }
            Payment.STATUS_FAILED -> {
                Text(
                    text = "Payment Failed",
                    style = typography.toMaterialTypography(colorPalette).bodyLarge,
                    color = MaterialTheme.colorScheme.error
                )
            }
        }
    }
}