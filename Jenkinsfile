pipeline {
    agent any

    tools {
        maven 'maven' // Name configured in Jenkins Global Tool Configuration
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

        stage('Set Version') {
            steps {
                script {
                    // Get short Git commit hash (e.g. 'a1b2c3d')
                    def gitCommit = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    env.BUILD_VERSION = "1.0.0-${gitCommit}"
                    echo "Build version set to ${env.BUILD_VERSION}"
                }
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package'
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
                    sh 'mvn clean verify sonar:sonar ' +
                       '-Dsonar.projectKey=JavaLoginApp ' +
                       '-Dsonar.projectName="Java Login App" ' +
                       '-Dsonar.projectVersion=1.0'
                }
            }
        }

        stage('Upload to Nexus') {
            steps {
                nexusArtifactUploader artifacts: [[
                    artifactId: 'dptweb',
                    classifier: '',
                    file: 'target/dptweb-1.0.war',
                    type: 'war'
                ]],
                credentialsId: 'nexus',
                groupId: 'com.example',
                nexusUrl: 'localhost:8081',
                nexusVersion: 'nexus3',
                protocol: 'http',
                repository: 'sample',
                version: '1.0'
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: "target/dptweb-${env.BUILD_VERSION}.war", allowEmptyArchive: true
            junit 'target/surefire-reports/*.xml'
        }
    }
}
// Jenkinsfile for Java Login App project
// This file defines the CI/CD pipeline for building, testing, and deploying the Java Login App
// It includes stages for checkout, build, test, SonarQube analysis, and uploading to Nexus
// The pipeline uses Maven for building and testing, and integrates with SonarQube for code quality analysis
// It also uploads the built artifact to a Nexus repository
// The pipeline is configured to run on any available agent and uses credentials stored in Jenkins for Nexus