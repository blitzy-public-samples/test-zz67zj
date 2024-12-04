/**
 * Project structure configuration for the Dog Walker Android application.
 *
 * Requirement addressed: Build Configuration Management
 * Location: Technical Specification/9.5 Development & Deployment/Build & Deployment
 * Ensures consistent and optimized build configurations for the Android application.
 */

// Configure project-level settings
pluginManagement {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}

// Configure dependency resolution repositories
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

// Set the root project name
rootProject.name = "DogWalker"

// Include the application module
include(":app")