// androidx.compose.material3:material3 version: 1.1.2
// androidx.compose.foundation:foundation version: 1.5.4
// androidx.compose.runtime:runtime version: 1.5.4

package com.dogwalker.app.presentation.components

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.dogwalker.app.domain.model.Booking
import com.dogwalker.app.presentation.theme.Theme
import java.text.NumberFormat
import java.util.*

/**
 * Human Tasks:
 * 1. Verify that the card dimensions match the design system specifications
 * 2. Ensure text content meets minimum contrast ratios for accessibility
 * 3. Test the component with different booking data lengths to verify proper text truncation
 */

/**
 * A card component that displays booking details including user information,
 * dog details, walk schedule, and payment information.
 *
 * Requirements addressed:
 * - 8.1.1 Design Specifications
 *   Implements a visually consistent card component following Material Design 3 guidelines
 *   with proper spacing, typography, and color usage.
 *
 * @param booking The booking data to display
 * @param theme The theme configuration for styling
 * @param modifier Optional modifier for the card
 */
@Composable
fun BookingCard(
    booking: Booking,
    theme: Theme,
    modifier: Modifier = Modifier
) {
    val currencyFormatter = NumberFormat.getCurrencyInstance(Locale.US)

    Card(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp),
        colors = CardDefaults.cardColors(
            containerColor = theme.colorPalette.surface,
            contentColor = theme.colorPalette.onSurface
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(
            modifier = Modifier
                .padding(16.dp)
                .fillMaxWidth()
        ) {
            // User and Dog Information
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = booking.userName,
                        style = theme.typography.titleMedium,
                        color = theme.colorPalette.onSurface,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = "Dog: ${booking.dogName}",
                        style = theme.typography.bodyMedium,
                        color = theme.colorPalette.onSurface.copy(alpha = 0.7f),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
                
                Text(
                    text = currencyFormatter.format(booking.paymentAmount),
                    style = theme.typography.titleLarge,
                    color = theme.colorPalette.primary
                )
            }

            Divider(
                modifier = Modifier
                    .padding(vertical = 12.dp)
                    .fillMaxWidth(),
                color = theme.colorPalette.onSurface.copy(alpha = 0.12f)
            )

            // Walk Schedule Information
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = "Date",
                        style = theme.typography.labelMedium,
                        color = theme.colorPalette.onSurface.copy(alpha = 0.6f)
                    )
                    Text(
                        text = booking.walkDate,
                        style = theme.typography.bodyMedium,
                        color = theme.colorPalette.onSurface
                    )
                }
                
                Spacer(modifier = Modifier.width(16.dp))
                
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = "Time",
                        style = theme.typography.labelMedium,
                        color = theme.colorPalette.onSurface.copy(alpha = 0.6f)
                    )
                    Text(
                        text = booking.walkTime,
                        style = theme.typography.bodyMedium,
                        color = theme.colorPalette.onSurface
                    )
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Rating Bar
            RatingBar(
                rating = 4.5f, // This should come from the booking data when available
                colorPalette = theme.colorPalette,
                shapeTheme = theme.shapeTheme,
                typography = theme.typography,
                onRatingChanged = { /* Handle rating changes if needed */ }
            )
        }
    }
}