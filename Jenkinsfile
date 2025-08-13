pipeline {
    agent any

    tools {
        maven 'maven' // Maven name from Jenkins Global Tool Configuration
    }

    environment {
        // Credentials
        NEXUS_CRED = credentials('nexus')
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_IMAGE = 'asue1/dptweb'
        DOCKER_CRED_ID = 'docker'

        // Versioning: from Git commit short SHA + Jenkins build number
        VERSION = ""
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    git url: 'https://github.com/AsueDerick/AsueDerick-DevOps-Project-01-Java-Login-app.git', branch: 'main'
                    def commitHash = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    VERSION = "${commitHash}-${env.BUILD_NUMBER}"
                    echo "Build Version: ${VERSION}"
                }
            }
        }

        stage('Build') {
            steps {
                sh "mvn clean package -DskipTests"
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
                        -Dsonar.projectVersion=${VERSION}
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
                        file: 'target/*.war',
                        type: 'war'
                    ]],
                    credentialsId: 'nexus',
                    groupId: 'com.example',
                    nexusUrl: 'localhost:8081', // Change to your Nexus server IP
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    repository: 'sample',
                    version: "${VERSION}"
                )
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${VERSION} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CRED_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push ${DOCKER_IMAGE}:${VERSION}
                        docker logout
                    """
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'target/*.war', allowEmptyArchive: true
            junit 'target/surefire-reports/*.xml'
        }
    }
}
// This Jenkinsfile defines a pipeline for building, testing, and deploying a Java web application.
// It includes stages for checking out the code, building the application, running tests, performing SonarQube analysis,
// uploading artifacts to Nexus, building a Docker image, and pushing it to a Docker registry.
// The pipeline uses environment variables for credentials and versioning, and it archives artifacts and test results at the end.
// Make sure to adjust the Nexus URL, Docker image name, and credentials IDs as per your environment setup.