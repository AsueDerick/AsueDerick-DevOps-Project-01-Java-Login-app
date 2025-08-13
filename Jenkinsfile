pipeline {
    agent any
tools {
        maven 'maven' // Name configured in Jenkins Global Tool Configuration
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
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Build & SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh 'mvn clean verify sonar:sonar ' +
                       '-Dsonar.projectKey=JavaLoginApp ' +
                       '-Dsonar.projectName="Java Login App" ' +
                       '-Dsonar.projectVersion=1.0'
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