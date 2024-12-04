# Requirement addressed: Code Optimization and Security
# Location: Technical Specification/9.5 Development & Deployment/Build & Deployment
# Ensures that the Android application is optimized and obfuscated to reduce APK size and protect intellectual property.

# Keep the application's base API URL
-keepclassmembers class com.dogwalker.app.util.Constants {
    public static final java.lang.String BASE_API_URL;
}

# Retrofit v2.9.0 rules
-keepattributes Signature
-keepattributes *Annotation*
-keep class retrofit2.** { *; }
-keepclasseswithmembers class * {
    @retrofit2.http.* <methods>;
}
-keepclassmembers,allowshrinking,allowobfuscation interface * {
    @retrofit2.http.* <methods>;
}

# OkHttp v4.9.3 rules
-dontwarn okhttp3.**
-dontwarn okio.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase
-keepclassmembers class okhttp3.** { *; }
-keep class okhttp3.** { *; }

# Gson rules (used by Retrofit's GsonConverterFactory v2.9.0)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Room Database v2.5.0 rules
-keep class * extends androidx.room.RoomDatabase
-keep @androidx.room.Entity class *
-dontwarn androidx.room.paging.**
-keep class * extends androidx.room.DatabaseConfiguration
-keepclassmembers class * extends androidx.room.RoomDatabase {
    abstract androidx.room.InvalidationTracker getInvalidationTracker();
}

# Keep data models used by Room and Retrofit
-keep class com.dogwalker.app.domain.model.** { *; }
-keep class com.dogwalker.app.data.database.entity.** { *; }

# Keep DAO interfaces
-keep interface com.dogwalker.app.data.database.dao.** { *; }

# Keep API interfaces
-keep interface com.dogwalker.app.data.api.ApiService { *; }

# General Android rules
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}
-keepclassmembers class * implements java.io.Serializable {
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep custom exceptions
-keep public class * extends java.lang.Exception

# Keep Android lifecycle components
-keep class * extends androidx.lifecycle.ViewModel {
    <init>();
}
-keep class * extends androidx.lifecycle.AndroidViewModel {
    <init>(android.app.Application);
}
-keep class * extends androidx.lifecycle.LiveData { *; }

# Keep Kotlin coroutines
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}

# Keep Dagger Hilt components
-keep class dagger.** { *; }
-keep class javax.inject.** { *; }
-keep class * extends dagger.hilt.android.internal.managers.ApplicationComponentManager { *; }