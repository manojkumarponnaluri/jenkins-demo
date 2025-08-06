@Library('shared-lib') _
import org.example.Utils

pipeline {
    agent any

    environment {
        // 🌐 Docker Hub
        DOCKER_CREDENTIALS_ID = 'docker-hub-creds'
        DOCKER_HUB_REPO = '7995360438/jenkins-demo'

        // 🌐 Harbor Registry
        HARBOR_REGISTRY = '192.168.0.12:8080'
        HARBOR_IMAGE = "${HARBOR_REGISTRY}/library/jenkins-demo"
        HARBOR_CREDENTIALS_ID = 'harbor-creds'

        // 🔐 MinIO
        MINIO_CREDENTIALS_ID = 'minio-creds'
        MINIO_HOST = '192.168.0.21' // ⬅️ Replace this with your RPi VM IP
        MINIO_BUCKET = 'build-artifacts'

        // 🔔 Notifications
        DISCORD_WEBHOOK = credentials('DISCORD_WEBHOOK')
    }

    stages {
        stage('Greet from Shared Lib') {
            steps {
                greet('Manoj')
            }
        }

        stage('Shout Message from Shared Lib') {
            steps {
                script {
                    def msg = Utils.shout('this is from shared lib')
                    echo msg
                }
            }
        }

        stage('Greet') {
            steps {
                echo ' ~K Hello from Jenkins! Let’s build and push Docker image.'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo ' M-3 Building Docker image...'
                    dockerImage = docker.build("${DOCKER_HUB_REPO}:latest")
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    echo ' ~@ Pushing image to Docker Hub...'
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDENTIALS_ID) {
                        dockerImage.push("latest")
                    }
                }
            }
        }

        stage('Tag Image for Harbor') {
            steps {
                script {
                    echo '🏷️ Tagging image for Harbor...'
                    sh "docker tag ${DOCKER_HUB_REPO}:latest ${HARBOR_IMAGE}:latest"
                }
            }
        }

        stage('Push to Harbor') {
            steps {
                script {
                    echo '🚢 Pushing image to Harbor...'
                    withCredentials([usernamePassword(credentialsId: HARBOR_CREDENTIALS_ID, usernameVariable: 'HARBOR_USER', passwordVariable: 'HARBOR_PASS')]) {
                        sh """
                        docker login -u $HARBOR_USER -p $HARBOR_PASS ${HARBOR_REGISTRY}
                        docker push ${HARBOR_IMAGE}:latest
                        docker logout ${HARBOR_REGISTRY}
                        """
                    }
                }
            }
        }

        stage('Upload to MinIO') {
            steps {
                script {
                    echo '🗃️ Uploading build output to MinIO...'
                }
                withCredentials([usernamePassword(credentialsId: MINIO_CREDENTIALS_ID, usernameVariable: 'MINIO_USER', passwordVariable: 'MINIO_PASS')]) {
                    sh """
                    curl -X PUT -T ./build/output.zip http://$MINIO_USER:$MINIO_PASS@${MINIO_HOST}:9000/${MINIO_BUCKET}/output.zip
                    """
                }
            }
        }
    }

    post {
        success {
            emailext(
                to: 'ponnalurimanojkumar@gmail.com',
                subject: "✅ SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: "The job has completed successfully!\nCheck details at: ${env.BUILD_URL}"
            )
            script {
                sh """
                curl -H "Content-Type: application/json" \\
                -X POST -d '{"content": "✅ Jenkins Job *SUCCESS*: ${env.JOB_NAME} #${env.BUILD_NUMBER} pushed to Docker Hub, Harbor, and uploaded to MinIO."}' \\
                $DISCORD_WEBHOOK
                """
            }
        }

        failure {
            emailext(
                to: 'ponnalurimanojkumar@gmail.com',
                subject: "❌ FAILURE: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: "The job has failed!\nCheck details at: ${env.BUILD_URL}"
            )
            script {
                sh """
                curl -H "Content-Type: application/json" \\
                -X POST -d '{"content": "❌ Jenkins Job *FAILED*: ${env.JOB_NAME} #${env.BUILD_NUMBER}"}' \\
                $DISCORD_WEBHOOK
                """
            }
        }

        always {
            sh "docker rmi ${DOCKER_HUB_REPO}:latest || true"
            sh "docker rmi ${HARBOR_IMAGE}:latest || true"
        }
    }
}
