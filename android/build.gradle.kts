

// --------------------------------------------------------------------------------
// 1. ADDED: PLUGINS BLOCK (REQUIRED FOR FIREBASE/FCM)
// This registers the Google Services plugin for the entire project.
// NOTE: Please verify that the 'version' numbers for the AGP and Kotlin match 
// what is currently being used in your Android setup.
// --------------------------------------------------------------------------------
// plugins {
//     // Defines the Android Gradle Plugin (AGP) dependency
//     id("com.android.application") version "8.9.1" apply false 
    
//     // Defines the Kotlin Android Plugin dependency
//     id("org.jetbrains.kotlin.android") version "1.9.23" apply false 
    
//     // Defines the Google Services (Firebase) Gradle Plugin dependency
//     id("com.google.gms.google-services") version "4.4.1" apply false 
// }



allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
