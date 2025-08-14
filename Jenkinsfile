pipeline {
    agent any

    tools {
        maven 'maven' // Jenkins Maven tool name
    }

    environment {
        NEXUS_CRED = credentials('nexus')
        DOCKER_CRED_ID = 'docker'
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_IMAGE = 'asue1/dptweb'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/AsueDerick/AsueDerick-DevOps-Project-01-Java-Login-app.git', branch: 'main'
            }
        }

        stage('Build WAR') {
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
                        -Dsonar.projectName='Java Login App'
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
                file: 'target/dptweb-1.0.0.war',  // specify the WAR file explicitly
                type: 'war'
            ]],
            credentialsId: 'nexus',
            groupId: 'com.example',
            nexusUrl: 'localhost:8081',
            nexusVersion: 'nexus3',
            protocol: 'http',
            repository: 'sample',
            version: '1.0.0'  // or any fixed version
        )
    }
}

        stage('Build Docker Image') {
            steps {
                sh "docker build --build-arg WAR_FILE=target/dptweb-*.war -t ${DOCKER_IMAGE}:latest ."
            }
        }

        stage('Push Docker Image') {
    steps {
        withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            sh """
                echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                docker push ${DOCKER_IMAGE}:latest
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
