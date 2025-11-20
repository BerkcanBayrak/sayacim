# Flutter Wrapper
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keepclassmembers class kotlin.** { *; }
-keep interface kotlin.** { *; }

# Google Generative AI
-keep class com.google.ai.** { *; }
-keep class com.google.generativeai.** { *; }
-keep class com.google.protobuf.** { *; }
-keepclassmembers class com.google.generativeai.** { *; }
-keep interface com.google.generativeai.** { *; }

# Google Play Core (for deferred components)
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }
-keepclassmembers class com.google.android.play.core.** { *; }

# OkHttp
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-keep class okio.** { *; }
-keep interface okio.** { *; }

# Retrofit
-keep class retrofit2.** { *; }
-keep interface retrofit2.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# JSON serialization (for GSON/JSON)
-keep class com.google.gson.** { *; }
-keep interface com.google.gson.** { *; }
-keep class **.R$* { *; }

# Keep all model classes
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Preserve source file names and line numbers for stack traces
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
