If you need to publish AAR to a third party maven repository, you can use the template below by filling 

your project and maven information to do the publishing.

```groovy
apply plugin: 'maven-publish'

android {
    // ...
}

task sourcesJar(type: Jar) {
    from android.sourceSets.main.java.srcDirs
    classifier = 'sources'
}

task javadoc(type: Javadoc) {
    source = android.sourceSets.main.java.srcDirs
    classpath += project.files(android.getBootClasspath().join(File.pathSeparator))
}

task javadocJar(type: Jar, dependsOn: javadoc) {
    classifier = 'javadoc'
    from javadoc.destinationDir
}

afterEvaluate {
    javadoc.classpath += files(android.libraryVariants.collect { variant ->
        variant.javaCompile.classpath.files
    })
}

artifacts {
    archives javadocJar
    archives sourcesJar
}

// run these two task to publish
task publishSNAPSHOT(dependsOn: publish)
task publishRELEASES(dependsOn: publish)

configure(publishSNAPSHOT) {
    group = 'publishing'
    description = 'Publish snapshot version to your maven repository'
}
configure(publishRELEASES) {
    group = 'publishing'
    description = 'Publish release version to your maven repository'
}

group = 'com.company.example'
version = '1.0.0'

// replace with your maven repository url
def snapshotsRepoUrl = 'http://maven.company.com/nexus/content/repositories/thirdparty-snapshots'
def releasesRepoUrl = 'http://maven.company.com/nexus/content/repositories/thirdparty'

gradle.taskGraph.whenReady { taskGraph ->
    if (taskGraph.allTasks.any {
        it.name.endsWith(publishSNAPSHOT.name) }) {
        publishing.publications.aar.version += '-SNAPSHOT'
        publishing.repositories.maven.url = snapshotsRepoUrl
    }
}

publishing {
    publications {
        aar(MavenPublication) {
            // groupId 'com.company.example'
            artifactId project.name
            // version '1.0.0-SNAPSHOT'

            artifact(sourcesJar)
            artifact(javadocJar)
            artifact("$buildDir/outputs/aar/${artifactId}-release.aar")

            pom.withXml {
                def dependenciesNode = asNode().appendNode('dependencies')

                // Iterate over the implementation dependencies (we don't want the test ones), adding a <dependency> node for each
                configurations.implementation.allDependencies.each {
                    // Ensure dependencies such as fileTree are not included.
                    if (it.name != 'unspecified') {
                        def dependencyNode = dependenciesNode.appendNode('dependency')
                        dependencyNode.appendNode('groupId', it.group)
                        dependencyNode.appendNode('artifactId', it.name)
                        dependencyNode.appendNode('version', it.version)
                    }
                }
            }
        }
    }

    repositories {
        maven {
            url = releasesRepoUrl
            // replace with your credential information
            credentials {
                username 'username'
                password 'password'
            }
        }
    }
}

dependencies {
    // ...
}
```

After apply the configuration above, you just run the task `publishRELEASES` or `publishSNAPSHOT` from gradle to have your AAR,
JavadocJar and SourcesJar published to your personal maven repository.
