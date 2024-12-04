package com.dogwalker.app.service

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.Manifest
import androidx.core.app.NotificationCompat // androidx.core:core-ktx:1.6.0
import androidx.core.content.ContextCompat // androidx.core:core-ktx:1.6.0
import com.dogwalker.app.R
import com.dogwalker.app.util.Constants.BASE_API_URL
import com.dogwalker.app.util.PermissionUtils
import com.dogwalker.app.data.api.ApiService

/**
 * Human Tasks:
 * 1. Verify that notification icons are properly set in the app's drawable resources
 * 2. Ensure notification permission is declared in AndroidManifest.xml
 * 3. Test notification behavior on different Android versions (especially 8.0+ for channels)
 * 4. Confirm notification sound and vibration patterns meet UX requirements
 */

/**
 * Service responsible for managing and sending notifications in the Dog Walker application.
 *
 * Requirement addressed: Push Notifications (1.2 System Overview/Real-time Features)
 * Implements notification management for booking updates, walk status, and user interactions.
 */
object NotificationService {

    private const val NOTIFICATION_CHANNEL_ID = "dog_walker_notifications"
    private const val NOTIFICATION_CHANNEL_NAME = "Dog Walker Notifications"
    private const val NOTIFICATION_ID = 1001

    /**
     * Creates a notification channel for Android O (API 26) and above.
     *
     * @param context The application context
     */
    fun createNotificationChannel(context: Context) {
        // Only create notification channels for Android O and above
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                NOTIFICATION_CHANNEL_NAME,
                importance
            ).apply {
                description = "Channel for Dog Walker app notifications"
                enableLights(true)
                enableVibration(true)
            }

            // Register the channel with the system
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) 
                as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    /**
     * Sends a notification to the user.
     *
     * @param context The application context
     * @param title The title of the notification
     * @param message The message content of the notification
     */
    fun sendNotification(context: Context, title: String, message: String) {
        if (!checkNotificationPermission(context)) {
            return
        }

        val notificationBuilder = NotificationCompat.Builder(context, NOTIFICATION_CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification) // Make sure this icon exists in drawable
            .setContentTitle(title)
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)

        val notificationManager = ContextCompat.getSystemService(
            context,
            NotificationManager::class.java
        ) as NotificationManager

        notificationManager.notify(NOTIFICATION_ID, notificationBuilder.build())
    }

    /**
     * Checks if the app has permission to send notifications.
     *
     * @param context The application context
     * @return Boolean indicating if notification permission is granted
     */
    fun checkNotificationPermission(context: Context): Boolean {
        // For Android 13 (API 33) and above, check POST_NOTIFICATIONS permission
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            PermissionUtils.checkPermission(
                context,
                Manifest.permission.POST_NOTIFICATIONS
            )
        } else {
            // For older versions, notifications were enabled by default
            true
        }
    }

    /**
     * Sends a booking confirmation notification.
     *
     * @param context The application context
     * @param bookingId The ID of the confirmed booking
     */
    private fun sendBookingConfirmationNotification(context: Context, bookingId: String) {
        sendNotification(
            context,
            "Booking Confirmed",
            "Your dog walking booking #$bookingId has been confirmed!"
        )
    }

    /**
     * Sends a walk start notification.
     *
     * @param context The application context
     * @param walkerName The name of the dog walker
     */
    private fun sendWalkStartNotification(context: Context, walkerName: String) {
        sendNotification(
            context,
            "Walk Started",
            "Your dog's walk with $walkerName has begun!"
        )
    }

    /**
     * Sends a walk completion notification.
     *
     * @param context The application context
     * @param duration The duration of the walk in minutes
     */
    private fun sendWalkCompletionNotification(context: Context, duration: Int) {
        sendNotification(
            context,
            "Walk Completed",
            "Your dog's $duration minute walk has been completed successfully!"
        )
    }
}