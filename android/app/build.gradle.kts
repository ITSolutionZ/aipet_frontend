plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.itz.aipet"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.itz.aipet"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // 환경 변수에서 API 키 가져오기
        val googleMapsApiKey = System.getenv("GOOGLE_MAPS_API_KEY") ?: "AIzaSyA3cKQUER5YaPEi5-9iWP_n5rFcXzlRn6c"
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = googleMapsApiKey

        // API 키가 설정되지 않은 경우 경고 출력
        if (System.getenv("GOOGLE_MAPS_API_KEY") == null) {
            println("⚠️  GOOGLE_MAPS_API_KEY 환경 변수가 설정되지 않았습니다. 기본값을 사용합니다.")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
