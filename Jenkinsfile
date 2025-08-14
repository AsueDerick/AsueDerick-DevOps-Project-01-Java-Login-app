pipeline {
    agent any

    tools {
        maven 'maven'
    }

    environment {
        NEXUS_CRED = credentials('nexus')
        DOCKER_CRED_ID = 'docker'
        DOCKER_IMAGE = 'asue1/dptweb'
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
                sh "mvn clean package -DskipTests"
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
                    // Detect the generated WAR dynamically
                    def warFile = sh(script: "ls target/dptweb-*.war", returnStdout: true).trim()
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
                        version: env.BUILD_VERSION
                    )
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    // Detect WAR dynamically
                    def warFile = sh(script: "ls target/dptweb-*.war", returnStdout: true).trim()
                    
                    // Build Docker image
                    sh "docker build --build-arg WAR_FILE=${warFile} -t ${DOCKER_IMAGE}:${env.BUILD_VERSION} ."
                }

                withCredentials([usernamePassword(credentialsId: "${docker}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push ${DOCKER_IMAGE}:${env.BUILD_VERSION}
                        docker logout
                    """
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
