# Keep Firebase and messaging models
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Keep Flutter plugins that use reflection
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.plugins.**

# Keep Gson/JSON models if using reflection
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Keep Kotlin metadata
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**

# Keep your app models and data classes (adjust package as needed)
-keep class com.absenkasau.app.** { *; }

# TensorFlow Lite rules
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**
-keep class org.tensorflow.lite.gpu.** { *; }
-dontwarn org.tensorflow.lite.gpu.**

# Keep TensorFlow Lite GPU delegate
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegate { *; }
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options

# ML Kit Face Detection
-keep class com.google.mlkit.vision.face.** { *; }
-dontwarn com.google.mlkit.vision.face.**

# Camera and image processing
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

# Mobile Scanner (QR/Barcode)
-keep class dev.steenbakker.mobile_scanner.** { *; }
-dontwarn dev.steenbakker.mobile_scanner.**

# Geolocator
-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**

# Google Maps
-keep class com.google.android.gms.maps.** { *; }
-keep class com.google.android.gms.location.** { *; }
-dontwarn com.google.android.gms.**

# Flutter Local Notifications
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**
