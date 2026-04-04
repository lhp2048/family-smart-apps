import com.android.build.api.dsl.ApplicationExtension
import com.android.build.api.dsl.LibraryExtension

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

// 插件子工程若沿用过低 compileSdk，会出现 resource android:attr/lStar not found
subprojects {
    afterEvaluate {
        extensions.findByType(LibraryExtension::class.java)?.apply { compileSdk = 35 }
        extensions.findByType(ApplicationExtension::class.java)?.apply { compileSdk = 35 }
    }
}

// isar_flutter_libs 3.1.0+1 未声明 namespace，AGP 8+ 会报错（与 Manifest package 一致）
subprojects {
    plugins.withId("com.android.library") {
        if (name == "isar_flutter_libs") {
            val androidExt = extensions.getByName("android")
            val setNs =
                androidExt.javaClass.methods.firstOrNull { m ->
                    m.name == "setNamespace" && m.parameterTypes.size == 1 &&
                        m.parameterTypes[0] == String::class.java
                }
            setNs?.invoke(androidExt, "dev.isar.isar_flutter_libs")
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
