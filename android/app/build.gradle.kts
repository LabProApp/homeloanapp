plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.keybricks"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("release") {
            // Set these environment variables in CI/CD or provide a local keystore.properties file.
            // KEYSTORE_PATH  — absolute path to your .jks / .keystore file
            // KEYSTORE_PASS  — keystore password
            // KEY_ALIAS      — key alias inside the keystore
            // KEY_PASS       — key password
            val keystorePath = System.getenv("KEYSTORE_PATH") ?: ""
            val keystorePass = System.getenv("KEYSTORE_PASS") ?: ""
            val keyAlias     = System.getenv("KEY_ALIAS")     ?: ""
            val keyPass      = System.getenv("KEY_PASS")      ?: ""

            if (keystorePath.isNotEmpty()) {
                storeFile     = file(keystorePath)
                storePassword = keystorePass
                this.keyAlias = keyAlias
                keyPassword   = keyPass
            }
        }
    }

    defaultConfig {
        applicationId = "com.keybricks"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            val hasKeystore = System.getenv("KEYSTORE_PATH")?.isNotEmpty() == true
            signingConfig = if (hasKeystore)
                signingConfigs.getByName("release")
            else
                signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
