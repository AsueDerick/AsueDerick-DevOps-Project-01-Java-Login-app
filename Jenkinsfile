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
        AWS_REGION     = 'ap-southeast-2'
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

        stage('Build Docker Image') {
            steps {
                sh "docker build --build-arg WAR_FILE=target/dptweb-${env.APP_VERSION}.war -t ${DOCKER_IMAGE}:${env.APP_VERSION} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CRED_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push ${DOCKER_IMAGE}:${env.APP_VERSION}
                        docker logout
                    """
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh 'terraform init'
                    sh 'terraform plan -out=tfplan'
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }

        stage('Provision IPv6 VPC') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh """
                        aws cloudformation deploy \
                            --template-file amazon-eks-ipv6-vpc-public-private-subnets.yaml \
                            --stack-name my-stack \
                            --region ${AWS_REGION} \
                            --capabilities CAPABILITY_NAMED_IAM
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
