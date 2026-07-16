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

subprojects {
    val buildFile = File(project.projectDir, "build.gradle")
    if (buildFile.exists()) {
        var content = buildFile.readText()
        if (content.contains("android {")) {
            if (!content.contains("namespace")) {
                val manifestFile = File(project.projectDir, "src/main/AndroidManifest.xml")
                var packageName = "com.example.${project.name.replace("-", "_")}"
                if (manifestFile.exists()) {
                    val manifestContent = manifestFile.readText()
                    val matcher = Regex("""package\s*=\s*['"]([^'"]+)['"]""").find(manifestContent)
                    if (matcher != null) {
                        packageName = matcher.groupValues[1]
                    }
                }
                content = content.replaceFirst("android {", "android {\n    namespace = \"$packageName\"\n")
            }
            content = content.replace(Regex("""compileSdkVersion\s+\d+"""), "compileSdkVersion 36")
            content = content.replace(Regex("""compileSdk\s+\d+"""), "compileSdk 36")
            buildFile.writeText(content)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
