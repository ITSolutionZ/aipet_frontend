plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.itz.aipet"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

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
        minSdk = 25
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // gradle.properties에서 API 키 가져오기 (gradle.properties -> 환경 변수 -> 기본값 순)
        val googleMapsApiKey = project.findProperty("GOOGLE_MAPS_API_KEY") as String?
            ?: System.getenv("GOOGLE_MAPS_API_KEY")
            ?: System.getenv("GOOGLE_PUBLIC_API_KEY")
            ?: "AIzaSyDgutqY6sdUtjQ_nCZOfb5_GwZmz7mHiAY"
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = googleMapsApiKey

        // API 키 설정 상태 출력
        when {
            project.findProperty("GOOGLE_MAPS_API_KEY") != null -> {
                println("✅ gradle.properties에서 GOOGLE_MAPS_API_KEY를 사용합니다.")
            }
            System.getenv("GOOGLE_MAPS_API_KEY") != null -> {
                println("✅ GOOGLE_MAPS_API_KEY 환경 변수를 사용합니다.")
            }
            System.getenv("GOOGLE_PUBLIC_API_KEY") != null -> {
                println("✅ GOOGLE_PUBLIC_API_KEY 환경 변수를 사용합니다.")
            }
            else -> {
                println("⚠️  Google Maps API 키가 설정되지 않았습니다. 기본값을 사용합니다.")
            }
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")

            // ProGuard 설정
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
