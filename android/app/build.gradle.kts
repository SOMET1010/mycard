plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.mycard"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.my.mycard"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Configuration de signature pour la production
            // Les valeurs doivent être fournies via des variables d'environnement ou gradle.properties
            storeFile = file(System.getenv("MYCARD_KEYSTORE_PATH") ?: "keystore.jks")
            storePassword = System.getenv("MYCARD_KEYSTORE_PASSWORD") ?: ""
            keyAlias = System.getenv("MYCARD_KEY_ALIAS") ?: "upload"
            keyPassword = System.getenv("MYCARD_KEY_PASSWORD") ?: ""
        }
    }

    buildTypes {
        release {
            // Activer la minification et l'obfuscation avec R8
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // Utiliser la configuration de signature de production si disponible
            // Sinon, utiliser debug pour le développement local
            signingConfig = if (System.getenv("MYCARD_KEYSTORE_PATH") != null) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
