pipeline {
    agent any

    tools {
        maven 'maven'
    }

    environment {
        NEXUS_CRED = credentials('nexus')
        BUILD_VERSION = ""  // Will be set dynamically from Git commit
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/AsueDerick/AsueDerick-DevOps-Project-01-Java-Login-app.git', branch: 'main'
            }
        }

        stage('Set Version') {
            steps {
                script {
                    // Get short Git commit hash
                    def gitCommit = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    env.BUILD_VERSION = "1.0.0-${gitCommit}"
                    echo "Build version set to ${env.BUILD_VERSION}"
                }
            }
        }

        stage('Build') {
            steps {
                // Build WAR using Maven with dynamic revision
                sh "mvn clean package -Drevision=${env.BUILD_VERSION} -DskipTests"
            }
        }

        stage('Test') {
            steps {
                sh "mvn test"
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh """
                        mvn sonar:sonar \
                        -Dsonar.projectKey=JavaLoginApp \
                        -Dsonar.projectName='Java Login App' \
                        -Dsonar.projectVersion=${env.BUILD_VERSION}
                    """
                }
            }
        }

        stage('Upload to Nexus') {
            steps {
                nexusArtifactUploader(
                    artifacts: [[
                        artifactId: 'dptweb',
                        classifier: '',
                        file: 'target/dptweb-*.war', // use wildcard to match versioned WAR
                        type: 'war'
                    ]],
                    credentialsId: 'nexus',
                    groupId: 'com.example',
                    nexusUrl: 'localhost:8081',
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    repository: 'sample',
                    version: "${env.BUILD_VERSION}"
                )
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'target/dptweb-*.war', allowEmptyArchive: true
            junit 'target/surefire-reports/*.xml'
        }
    }
}
