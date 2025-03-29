# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.plugin.editing.** { *; }

# Keep notification plugins
-keep class com.dexterous.** { *; }

# For Google Play Services
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }

# For Google Play Core API
-keep class com.google.android.play.core.** { *; }

# Ignore warnings for missing Play Core classes
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
-dontwarn com.google.android.play.core.**

# For in-app purchase
-keep class com.android.billingclient.** { *; }