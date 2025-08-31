plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace "com.example.plant_diagnosis_fixed"
    compileSdkVersion flutter.compileSdkVersion
    ndkVersion flutter.ndkVersion

    defaultConfig {
        // هذا الـ applicationId لازم يظل مثل namespace عشان تطابق
        applicationId "com.example.plant_diagnosis_fixed"
        minSdkVersion flutter.minSdkVersion
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
            minifyEnabled false
            shrinkResources false
        }
    }
}


flutter {
    source = "../.."
}
