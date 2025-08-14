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

        // Versioning: will be set dynamically from Git + Jenkins build number
        VERSION = ""
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    git url: 'https://github.com/AsueDerick/AsueDerick-DevOps-Project-01-Java-Login-app.git', branch: 'main'
                    def commitHash = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    env.VERSION = "${commitHash}-${env.BUILD_NUMBER}"
                    echo "Build Version: ${env.VERSION}"
                }
            }
        }

        stage('Build WAR') {
            steps {
                script {
                    // Build WAR with Maven and dynamic revision
                    sh "mvn clean package -Drevision=${env.VERSION} -DskipTests"
                }
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
                        file: 'target/dptweb-*.war',  // wildcard for generated WAR
                        type: 'war'
                    ]],
                    credentialsId: 'nexus',
                    groupId: 'com.example',
                    nexusUrl: 'localhost:8081', // change if needed
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    repository: 'sample',
                    version: "${VERSION}"
                )
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build --build-arg WAR_FILE=target/dptweb-*.war -t ${DOCKER_IMAGE}:${VERSION} ."
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
            archiveArtifacts artifacts: 'target/dptweb-*.war', allowEmptyArchive: true
            junit 'target/surefire-reports/*.xml'
        }
    }
}
