import java.io.File
import java.io.FileInputStream
import java.time.LocalDate
import java.util.Properties
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load the release signing details from android/key.properties when it exists.
// The file (and the keystore it points to) are git-ignored and never committed.
// When it is absent, the release build falls back to the debug key so the app is
// still buildable without the secrets (e.g. for CI or a fresh checkout).
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseSigning = keystorePropertiesFile.exists()
if (hasReleaseSigning) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    FileInputStream(localPropertiesFile).use(localProperties::load)
}

// Regenerate the About-screen build metadata (app version + build date) before
// the Dart code is compiled, so every build ships the right values.
val flutterSdkPath = localProperties.getProperty("flutter.sdk")
    ?: System.getenv("FLUTTER_ROOT")
    ?: throw GradleException(
        "Flutter SDK path not found. Set flutter.sdk in android/local.properties or FLUTTER_ROOT."
    )

val isWindowsHost = System.getProperty("os.name").startsWith("Windows", ignoreCase = true)
val dartExecutable = File(
    flutterSdkPath,
    if (isWindowsHost) "bin/dart.bat" else "bin/dart",
)
val projectRootDir = rootProject.projectDir.parentFile

fun registerMetadataGenerator(taskName: String, scriptPath: String, outputPath: String) =
    tasks.register<Exec>(taskName) {
        group = "build setup"
        description = "Generates About-screen build metadata before Android builds."

        inputs.file(projectRootDir.resolve("pubspec.yaml"))
        inputs.file(projectRootDir.resolve(scriptPath))
        inputs.property("metadataBuildDate", LocalDate.now().toString())
        outputs.file(projectRootDir.resolve(outputPath))

        workingDir = projectRootDir
        commandLine(dartExecutable.absolutePath, "run", scriptPath)

        doFirst {
            if (!dartExecutable.exists()) {
                throw GradleException(
                    "Could not find Dart executable at ${dartExecutable.absolutePath}. " +
                        "Check android/local.properties flutter.sdk or FLUTTER_ROOT."
                )
            }
        }
    }

val generateAppVersion = registerMetadataGenerator(
    "generateAppVersion",
    "tool/generate_app_version.dart",
    "lib/core/constants/app_version.g.dart",
)
val generateBuildDate = registerMetadataGenerator(
    "generateBuildDate",
    "tool/generate_build_date.dart",
    "lib/core/constants/build_date.g.dart",
)

val generateBuildMetadata = tasks.register("generateBuildMetadata") {
    group = "build setup"
    description = "Generates all About-screen build metadata."
    dependsOn(generateAppVersion, generateBuildDate)
}

tasks.named("preBuild") {
    dependsOn(generateBuildMetadata)
}

tasks.matching { task ->
    task.name.startsWith("compileFlutterBuild")
}.configureEach {
    dependsOn(generateBuildMetadata)
}

android {
    namespace = "in.sreerajp.lyricchord"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "in.sreerajp.lyricchord"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = keystoreProperties["storeFile"]?.let { rootProject.file(it) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    // The app has its own language picker (English, Malayalam, Sanskrit). Keep
    // every language's resources in the App Bundle, so Google Play does not
    // install only the phone's language (engineering standard §8.1).
    bundle {
        language {
            enableSplit = false
        }
    }

    // AGP 9 turns custom resource values off by default. The flavors below use
    // resValue to give each install its own app name, so turn them back on.
    buildFeatures {
        resValues = true
    }

    flavorDimensions += "environment"
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "LyricChord Dev")
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "LyricChord")
        }
    }

    buildTypes {
        release {
            // Sign with the app's release keystore when android/key.properties is
            // present; otherwise fall back to the debug key so the build still runs.
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17 // match compileOptions above
    }
}

flutter {
    source = "../.."
}

dependencies {
    // AppCompat themes for LaunchTheme / NormalTheme. local_auth (Stage Lock)
    // needs an AppCompat theme, or its prompt can crash on Android 8 and below.
    // A local UI library only — no network code.
    implementation("androidx.appcompat:appcompat:1.7.0")
}
