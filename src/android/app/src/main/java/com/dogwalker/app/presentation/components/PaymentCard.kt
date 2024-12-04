// androidx.compose.material3:material3 version: 1.1.2
// androidx.compose.ui:ui version: 1.5.4
package com.dogwalker.app.presentation.components

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.dogwalker.app.domain.model.Payment
import com.dogwalker.app.presentation.theme.ColorPalette
import com.dogwalker.app.presentation.theme.ShapeTheme
import com.dogwalker.app.presentation.theme.Theme
import com.dogwalker.app.presentation.theme.Typography
import java.text.NumberFormat
import java.util.*

/**
 * Human Tasks:
 * 1. Verify that the payment status colors meet WCAG 2.1 accessibility contrast requirements
 * 2. Ensure the card elevation values align with the Material Design specifications
 * 3. Test the payment amount formatting with different locales and currency symbols
 */

/**
 * A composable function that renders a payment card displaying payment details.
 * 
 * Requirements addressed:
 * - Payments (1.3 Scope/Core Features/Payments)
 *   Provides a visual representation of payment details including amount,
 *   method, and status in a Material Design 3 card format.
 *
 * @param payment The payment details to display
 * @param modifier Optional modifier for customizing the card's layout
 */
@Composable
fun PaymentCard(
    payment: Payment,
    modifier: Modifier = Modifier
) {
    val colorPalette = Theme.LocalColorPalette.current
    val shapeTheme = Theme.LocalShapeTheme.current
    val typography = Theme.LocalTypography.current

    Card(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp),
        shape = CardDefaults.shape,
        colors = CardDefaults.cardColors(
            containerColor = colorPalette.surface,
        ),
        elevation = CardDefaults.cardElevation(
            defaultElevation = 2.dp
        )
    ) {
        Column(
            modifier = Modifier
                .padding(16.dp)
                .fillMaxWidth()
        ) {
            // Payment Amount
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = formatAmount(payment.amount),
                    style = typography.toMaterialTypography(colorPalette).titleLarge,
                    color = colorPalette.onBackground
                )
                PaymentStatusChip(payment.status)
            }

            Spacer(modifier = Modifier.height(8.dp))

            // Payment Method
            Text(
                text = formatPaymentMethod(payment.method),
                style = typography.toMaterialTypography(colorPalette).bodyMedium,
                color = colorPalette.onBackground,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )

            Spacer(modifier = Modifier.height(4.dp))

            // Payment ID
            Text(
                text = "ID: ${payment.id}",
                style = typography.toMaterialTypography(colorPalette).bodySmall,
                color = colorPalette.onBackground.copy(alpha = 0.7f),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}

@Composable
private fun PaymentStatusChip(status: String) {
    val colorPalette = Theme.LocalColorPalette.current
    val typography = Theme.LocalTypography.current

    val (backgroundColor, textColor) = when (status) {
        Payment.STATUS_COMPLETED -> colorPalette.secondary to colorPalette.onSecondary
        Payment.STATUS_PENDING -> colorPalette.primaryVariant to colorPalette.onPrimary
        Payment.STATUS_PROCESSING -> colorPalette.primary to colorPalette.onPrimary
        else -> colorPalette.surface to colorPalette.onSurface
    }

    Surface(
        color = backgroundColor,
        shape = MaterialTheme.shapes.small,
        modifier = Modifier.padding(4.dp)
    ) {
        Text(
            text = formatStatus(status),
            modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
            style = typography.toMaterialTypography(colorPalette).labelMedium,
            color = textColor
        )
    }
}

private fun formatAmount(amount: Double): String {
    return NumberFormat.getCurrencyInstance(Locale.getDefault()).format(amount)
}

private fun formatPaymentMethod(method: String): String {
    return when (method) {
        Payment.METHOD_CREDIT_CARD -> "Credit Card"
        Payment.METHOD_DEBIT_CARD -> "Debit Card"
        Payment.METHOD_PAYPAL -> "PayPal"
        else -> method.replaceFirstChar { it.uppercase() }
    }
}

private fun formatStatus(status: String): String {
    return status.replace("_", " ").replaceFirstChar { it.uppercase() }
}