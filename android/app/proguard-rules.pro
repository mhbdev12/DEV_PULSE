# Flutter Engine & Plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**

# Hive Database & Adapters
-keep class hive.** { *; }
-keep class com.hamza.devpulse.** { *; }

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# Audio Players & Share Plus
-keep class com.ryanheise.audioservice.** { *; }
-keep class dev.fluttercommunity.plus.share.** { *; }

# WorkManager ProGuard Rules (Ignored if not in classpath)
-dontwarn androidx.work.**