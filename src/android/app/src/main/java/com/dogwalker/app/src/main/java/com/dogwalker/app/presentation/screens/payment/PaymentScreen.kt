// External imports - androidx.compose.ui v1.5.0
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp

// Internal imports
import com.dogwalker.app.domain.model.Payment
import com.dogwalker.app.presentation.components.PaymentCard
import com.dogwalker.app.presentation.screens.payment.PaymentViewModel
import com.dogwalker.app.presentation.theme.Theme

/**
 * Human Tasks:
 * 1. Verify payment gateway integration is properly configured
 * 2. Ensure proper error handling for payment failures is implemented
 * 3. Test payment flow with different payment methods
 * 4. Verify accessibility features are properly implemented
 */

/**
 * PaymentScreen composable that displays the payment interface.
 *
 * Requirements addressed:
 * - Payments (1.3 Scope/Core Features/Payments)
 *   Implements the user interface for secure payment processing, automated billing,
 *   and receipt generation.
 * - User Interface Design (8.1 User Interface Design/8.1.1 Design Specifications)
 *   Ensures a visually consistent and user-friendly interface for payment interactions.
 */
@Composable
fun PaymentScreen(
    viewModel: PaymentViewModel,
    modifier: Modifier = Modifier
) {
    // Access theme components
    val colorPalette = Theme.LocalColorPalette.current
    val typography = Theme.LocalTypography.current

    // Observe ViewModel state
    val paymentStatus by viewModel.paymentStatus.collectAsState()
    val isProcessing by viewModel.isProcessing.collectAsState()
    val error by viewModel.error.collectAsState()

    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Payment Header
        Text(
            text = "Payment Details",
            style = typography.toMaterialTypography(colorPalette).headlineMedium,
            color = colorPalette.onBackground,
            modifier = Modifier.padding(bottom = 24.dp)
        )

        // Payment Card
        PaymentCard(
            payment = Payment(
                id = "PAYMENT_ID",
                amount = 50.0,
                method = Payment.METHOD_CREDIT_CARD,
                status = Payment.STATUS_PENDING,
                timestamp = System.currentTimeMillis()
            ),
            modifier = Modifier.fillMaxWidth()
        )

        Spacer(modifier = Modifier.height(24.dp))

        // Process Payment Button
        Button(
            onClick = {
                viewModel.processPayment(
                    Payment(
                        id = "PAYMENT_ID",
                        amount = 50.0,
                        method = Payment.METHOD_CREDIT_CARD,
                        status = Payment.STATUS_PENDING,
                        timestamp = System.currentTimeMillis()
                    )
                )
            },
            modifier = Modifier
                .fillMaxWidth()
                .height(56.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = colorPalette.primary,
                contentColor = colorPalette.onPrimary
            ),
            enabled = !isProcessing
        ) {
            if (isProcessing) {
                CircularProgressIndicator(
                    modifier = Modifier.size(24.dp),
                    color = colorPalette.onPrimary
                )
            } else {
                Text(
                    text = "Process Payment",
                    style = typography.toMaterialTypography(colorPalette).titleMedium
                )
            }
        }

        // Error Message
        error?.let { errorMessage ->
            Spacer(modifier = Modifier.height(16.dp))
            Text(
                text = errorMessage,
                style = typography.toMaterialTypography(colorPalette).bodyMedium,
                color = MaterialTheme.colorScheme.error,
                modifier = Modifier.padding(horizontal = 16.dp)
            )
        }

        // Payment Status
        paymentStatus?.let { success ->
            Spacer(modifier = Modifier.height(16.dp))
            Text(
                text = if (success) "Payment Successful" else "Payment Failed",
                style = typography.toMaterialTypography(colorPalette).bodyLarge,
                color = if (success) colorPalette.secondary else MaterialTheme.colorScheme.error,
                modifier = Modifier.padding(horizontal = 16.dp)
            )
        }
    }
}

/**
 * Preview composable for PaymentScreen
 */
@Preview(showBackground = true)
@Composable
fun PaymentScreenPreview() {
    val viewModel = PaymentViewModel(ProcessPaymentUseCase())
    PaymentScreen(viewModel = viewModel)
}