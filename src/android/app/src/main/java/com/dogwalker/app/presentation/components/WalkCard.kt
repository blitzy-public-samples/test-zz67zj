// androidx.compose.material3:material3 version: 1.1.2
// androidx.compose.foundation:foundation version: 1.5.4
// androidx.compose.runtime:runtime version: 1.5.4

package com.dogwalker.app.presentation.components

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.dogwalker.app.domain.model.Walk
import com.dogwalker.app.presentation.theme.Theme
import java.text.SimpleDateFormat
import java.util.*

/**
 * Human Tasks:
 * 1. Verify that the card dimensions match the Material Design 3 specifications
 * 2. Ensure touch targets meet accessibility minimum size of 48dp
 * 3. Review color contrast ratios for text elements against background
 */

/**
 * A custom card component that displays walk details in the Dog Walker application.
 * 
 * Requirements addressed:
 * - User Interface Design (8.1.1 Design Specifications)
 *   Implements Material Design 3 guidelines for card components with proper spacing,
 *   typography, and interactive elements.
 */
@Composable
fun WalkCard(
    modifier: Modifier = Modifier,
    walk: Walk,
    theme: Theme,
    onCardClick: (String) -> Unit = {}
) {
    var ratingBarValue by remember { mutableStateOf(0f) }

    Card(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp),
        shape = MaterialTheme.shapes.medium,
        colors = CardDefaults.cardColors(
            containerColor = theme.colorPalette.surface,
            contentColor = theme.colorPalette.onSurface
        ),
        onClick = { onCardClick(walk.id) }
    ) {
        Column(
            modifier = Modifier
                .padding(16.dp)
                .fillMaxWidth()
        ) {
            // Walk Status Header
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = formatWalkStatus(walk.status),
                    style = theme.typography.toMaterialTypography(theme.colorPalette).titleMedium,
                    color = getStatusColor(walk.status, theme)
                )
                
                Text(
                    text = formatWalkDuration(walk.startTime, walk.endTime),
                    style = theme.typography.toMaterialTypography(theme.colorPalette).bodyMedium,
                    color = theme.colorPalette.onSurface.copy(alpha = 0.7f)
                )
            }

            Spacer(modifier = Modifier.height(8.dp))

            // Walk Time Details
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.Start,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = androidx.compose.material.icons.Icons.Outlined.Schedule,
                    contentDescription = "Walk time",
                    tint = theme.colorPalette.onSurface.copy(alpha = 0.7f),
                    modifier = Modifier.size(20.dp)
                )
                
                Spacer(modifier = Modifier.width(8.dp))
                
                Text(
                    text = formatTimeRange(walk.startTime, walk.endTime),
                    style = theme.typography.toMaterialTypography(theme.colorPalette).bodyMedium,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Rating Bar
            RatingBar(
                rating = ratingBarValue,
                colorPalette = theme.colorPalette,
                shapeTheme = theme.shapeTheme,
                typography = theme.typography,
                onRatingChanged = { newRating ->
                    ratingBarValue = newRating
                }
            )
        }
    }
}

/**
 * Formats the walk status into a user-friendly display string.
 */
private fun formatWalkStatus(status: String): String {
    return when (status.lowercase()) {
        "scheduled" -> "Scheduled"
        "in_progress" -> "In Progress"
        "completed" -> "Completed"
        "cancelled" -> "Cancelled"
        "paused" -> "Paused"
        else -> status.replaceFirstChar { it.uppercase() }
    }
}

/**
 * Returns the appropriate color for the walk status.
 */
private fun getStatusColor(status: String, theme: Theme): androidx.compose.ui.graphics.Color {
    return when (status.lowercase()) {
        "in_progress" -> theme.colorPalette.primary
        "completed" -> theme.colorPalette.secondary
        "cancelled" -> theme.colorPalette.onBackground.copy(alpha = 0.6f)
        "paused" -> theme.colorPalette.onBackground.copy(alpha = 0.8f)
        else -> theme.colorPalette.onBackground
    }
}

/**
 * Formats the walk duration into a human-readable string.
 */
private fun formatWalkDuration(startTime: String, endTime: String): String {
    val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.getDefault())
    
    return try {
        val start = dateFormat.parse(startTime)
        val end = dateFormat.parse(endTime)
        
        if (start != null && end != null) {
            val durationMillis = end.time - start.time
            val hours = durationMillis / (1000 * 60 * 60)
            val minutes = (durationMillis / (1000 * 60)) % 60
            
            when {
                hours > 0 -> "$hours hr ${if (minutes > 0) "$minutes min" else ""}"
                minutes > 0 -> "$minutes min"
                else -> "< 1 min"
            }
        } else {
            "Invalid duration"
        }
    } catch (e: Exception) {
        "Invalid duration"
    }
}

/**
 * Formats the start and end times into a readable time range.
 */
private fun formatTimeRange(startTime: String, endTime: String): String {
    val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.getDefault())
    val timeFormat = SimpleDateFormat("h:mm a", Locale.getDefault())
    
    return try {
        val start = dateFormat.parse(startTime)
        val end = dateFormat.parse(endTime)
        
        if (start != null && end != null) {
            "${timeFormat.format(start)} - ${timeFormat.format(end)}"
        } else {
            "Invalid time range"
        }
    } catch (e: Exception) {
        "Invalid time range"
    }
}