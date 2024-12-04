# Dog Walker Android Module

This document provides an overview and setup instructions for the Android module of the Dog Walker application.

## Overview

The Dog Walker Android application is built using modern Android development practices and follows Material Design 3 guidelines. It implements features for dog walking services including user management, booking system, payment processing, and real-time walk tracking.

## Prerequisites

- Android Studio Arctic Fox (2021.3.1) or newer
- JDK 11 or newer
- Android SDK 33 (minimum SDK 21)
- Google Play Services (for Maps and Location)

## Project Setup

1. Clone the repository and open the `src/android` directory in Android Studio
2. Add the following environment variables to your `local.properties`:
   ```properties
   MAPS_API_KEY=your_google_maps_api_key
   BACKUP_API_KEY=your_backup_api_key
   ```

## Build Configuration

The project uses Gradle with Kotlin DSL for build configuration. Key dependencies include:

- Kotlin version: 1.9.0
- Android Gradle Plugin: 7.5.0
- Dagger Hilt: 2.44
- Room Database: 2.5.0
- Retrofit: 2.9.0
- OkHttp: 4.9.3
- Jetpack Compose: 1.5.4
- Material Design 3: 1.1.2

## Project Structure

```
src/android/
├── app/
│   ├── src/main/
│   │   ├── java/com/dogwalker/app/
│   │   │   ├── data/           # Data layer (repositories, database, API)
│   │   │   ├── domain/         # Domain layer (models, use cases)
│   │   │   ├── presentation/   # UI layer (screens, components)
│   │   │   ├── service/        # Background services
│   │   │   └── util/           # Utility classes
│   │   ├── res/                # Resources
│   │   └── AndroidManifest.xml
│   ├── build.gradle.kts        # App-level build configuration
│   └── proguard-rules.pro      # ProGuard configuration
├── build.gradle.kts            # Project-level build configuration
└── gradle.properties           # Gradle properties
```

## Key Features

1. **User Management**
   - Authentication (login/register)
   - User profile management
   - Dog profile management

2. **Booking System**
   - Schedule walks
   - View booking history
   - Real-time booking status

3. **Payment Processing**
   - Secure payment integration
   - Multiple payment methods
   - Transaction history

4. **Walk Tracking**
   - Real-time GPS tracking
   - Route recording
   - Walk status updates

## Development Guidelines

1. **Architecture**
   - MVVM architecture with Clean Architecture principles
   - Dependency injection using Dagger Hilt
   - Repository pattern for data management

2. **UI/UX**
   - Material Design 3 components
   - Dark mode support
   - Responsive layouts
   - Accessibility compliance

3. **Testing**
   - Unit tests for ViewModels and Use Cases
   - Integration tests for repositories
   - UI tests for critical flows

4. **Security**
   - ProGuard configuration for release builds
   - Secure storage for sensitive data
   - API key protection

## Building and Running

1. Debug Build:
   ```bash
   ./gradlew assembleDebug
   ```

2. Release Build:
   ```bash
   ./gradlew assembleRelease
   ```

3. Install on Device:
   ```bash
   ./gradlew installDebug
   ```

## Permissions

The application requires the following permissions:

- `ACCESS_FINE_LOCATION`: For GPS tracking
- `ACCESS_COARSE_LOCATION`: For approximate location
- `INTERNET`: For API communication
- `ACCESS_NETWORK_STATE`: For network connectivity
- `POST_NOTIFICATIONS`: For push notifications (Android 13+)

## Contributing

1. Follow the project's coding style and architecture
2. Write tests for new features
3. Update documentation for significant changes
4. Submit pull requests for review

## Troubleshooting

Common issues and solutions:

1. Build Errors
   - Clean and rebuild project
   - Invalidate caches and restart
   - Verify Gradle sync

2. Location Issues
   - Check Google Play Services version
   - Verify location permissions
   - Test with mock locations

3. API Connection
   - Verify network connectivity
   - Check API endpoint configuration
   - Review authentication tokens

## Resources

- [Android Developer Documentation](https://developer.android.com/docs)
- [Material Design Guidelines](https://m3.material.io/)
- [Kotlin Documentation](https://kotlinlang.org/docs/home.html)