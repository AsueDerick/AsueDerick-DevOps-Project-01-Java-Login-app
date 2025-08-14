pipeline {
    agent any

    tools {
        maven 'maven'
    }

    environment {
        NEXUS_CRED = credentials('nexus')
        BUILD_VERSION = ""
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
                    def gitCommit = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    env.BUILD_VERSION = "1.0.0-${gitCommit}"
                    echo "Build version set to ${env.BUILD_VERSION}"
                }
            }
        }

        stage('Build') {
            steps {
                sh "mvn clean package -Drevision=${env.BUILD_VERSION} -DskipTests"
            }
        }

        stage('Run Tests') {
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
                script {
                    // Find the generated WAR file dynamically
                    def warFile = sh(script: "ls target/*.war", returnStdout: true).trim()
                    echo "Uploading WAR file: ${warFile}"

                    nexusArtifactUploader(
                        artifacts: [[
                            artifactId: 'dptweb',
                            classifier: '',
                            file: warFile,
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
    }

    post {
        always {
            archiveArtifacts artifacts: 'target/dptweb-*.war', allowEmptyArchive: true
            junit 'target/surefire-reports/*.xml'
        }
    }
}
