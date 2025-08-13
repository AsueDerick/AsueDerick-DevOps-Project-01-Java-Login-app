pipeline {
    agent any

    tools {
        maven 'maven'
    }

    environment {
        NEXUS_CRED = credentials('nexus')
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
                    // Get short Git commit hash (e.g. 'a1b2c3d')
                    def gitCommit = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    env.BUILD_VERSION = "1.0.0-${gitCommit}"
                    echo "Build version set to ${env.BUILD_VERSION}"
                }
            }
        }

        stage('Build') {
            steps {
                sh "mvn clean package -Drevision=${env.BUILD_VERSION}"
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh "mvn sonar:sonar -Dsonar.projectVersion=${env.BUILD_VERSION} -Dsonar.projectKey=JavaLoginApp -Dsonar.projectName='Java Login App'"
                }
            }
        }

        stage('Upload to Nexus') {
            steps {
                nexusArtifactUploader artifacts: [[
                    artifactId: 'dptweb',
                    classifier: '',
                    file: "target/dptweb-${env.BUILD_VERSION}.war",
                    type: 'war'
                ]],
                credentialsId: 'nexus',
                groupId: 'com.example',
                nexusUrl: 'localhost:8081',
                nexusVersion: 'nexus3',
                protocol: 'http',
                repository: 'sample',
                version: "${env.BUILD_VERSION}"
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
