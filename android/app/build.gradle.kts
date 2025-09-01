plugins {
    id "com.android.application"
    id "org.jetbrains.kotlin.android"
    id "dev.flutter.flutter-gradle-plugin"
}

android {
    namespace "com.example.plant_diagnosis"
    compileSdk 35

    ndkVersion "27.0.12077973"

    defaultConfig {
        applicationId "com.example.plant_diagnosis"
        minSdk 21
        targetSdk 35
        versionCode 1
        versionName "1.0"

        multiDexEnabled true
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_11
        targetCompatibility JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            // مؤقتاً استخدم debug key عشان يشتغل
            signingConfig signingConfigs.debug
            minifyEnabled false
            shrinkResources false
        }
    }
}

flutter {
    source "../.."
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.9.22"
    implementation "androidx.multidex:multidex:2.0.1"
}
