
pipeline {
    agent any

    tools {
        maven 'maven' // Jenkins Maven tool name
    }

    environment {
        NEXUS_CRED      = credentials('nexus')
        DOCKER_CRED_ID  = 'docker'
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_IMAGE    = 'asue1/dptweb'
        AWS_REGION      = 'ap-southeast-2'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/AsueDerick/AsueDerick-DevOps-Project-01-Java-Login-app.git', branch: 'main'
            }
        }

        stage('Set Build Version') {
            steps {
                script {
                    // For dev builds, use SNAPSHOT; for releases, bump version with build number
                    if (env.BRANCH_NAME == 'main') {
                        env.APP_VERSION = "1.0.${env.BUILD_NUMBER}"
                    } else {
                        env.APP_VERSION = '1.0.0-SNAPSHOT'
                    }
                    sh "mvn versions:set -DnewVersion=${env.APP_VERSION}"
                }
            }
        }

        stage('Build WAR') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'mvn test'
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
                script {
                    nexusArtifactUploader(
                        artifacts: [[
                            artifactId: 'dptweb',
                            classifier: '',
                            file: "target/dptweb-${env.APP_VERSION}.war",
                            type: 'war'
                        ]],
                        credentialsId: 'nexus',
                        groupId: 'com.example',
                        nexusUrl: 'localhost:8081',
                        nexusVersion: 'nexus3',
                        protocol: 'http',
                        repository: env.BRANCH_NAME == 'main' ? 'sample' : 'maven-snapshots',
                        version: "${env.APP_VERSION}"
                    )
                }
            }
        }

        stage('Set Env Vars') {
            steps {
                script {
                    env.TRIVY_CACHE_DIR = '/tmp/.trivy/cache'
                    env.TRIVY_CONFIG_DIR = '/tmp/.trivy/config'
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'aws-creds',
                    usernameVariable: 'AWS_ACCESS_KEY_ID',
                    passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                )]) {
                    sh 'terraform init'
                    // sh 'terraform destroy -target=module.eks.module.eks_managed_node_group -auto-approve'
                    sh 'terraform plan -out=tfplan.binary'
                    sh 'terraform apply -auto-approve tfplan.binary'
                    sh 'aws eks --region ap-southeast-2 update-kubeconfig --name my-cluster'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build --build-arg WAR_FILE=target/dptweb-${env.APP_VERSION}.war -t ${DOCKER_IMAGE}:${env.APP_VERSION} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "${DOCKER_CRED_ID}",
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker tag ${DOCKER_IMAGE}:${env.APP_VERSION} ${DOCKER_IMAGE}:${env.APP_VERSION}
                        docker push ${DOCKER_IMAGE}:${env.APP_VERSION}
                        docker logout
                    """
                }
            }
        }
        stage('scan Docker Image with Trivy') {
            steps {
                script {
                    sh '''
                    trivy image ${DOCKER_IMAGE}:${env.APP_VERSION}
                    '''
                }
            }
        }
        stage('Deploy to EKS') {
            steps {
                script {
                    sh 'kubectl apply -f nginx-deployment.yaml'
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
