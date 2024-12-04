/**
 * Project-level build configuration for the Dog Walker Android application.
 *
 * Requirement addressed: Build Configuration Management
 * Location: Technical Specification/9.5 Development & Deployment/Build & Deployment
 * Ensures consistent and optimized build configurations for the Android application.
 */

// Top-level build file where you can add configuration options common to all sub-projects/modules.
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Android Gradle Plugin v7.5.0
        classpath("com.android.tools.build:gradle:7.5.0")
        // Kotlin Gradle Plugin v1.9.0
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0")
        // Dagger Hilt Gradle Plugin v2.44
        classpath("com.google.dagger:hilt-android-gradle-plugin:2.44")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}

/**
 * Project-wide Gradle configuration properties.
 * These properties are also defined in gradle.properties but can be overridden here if needed.
 */
gradle.projectsEvaluated {
    tasks.withType<JavaCompile> {
        options.compilerArgs.addAll(listOf("-Xmaxerrs", "500"))
    }
}

/**
 * Project structure configuration defining the included modules.
 * Currently includes only the main application module 'app'.
 */
include(":app")