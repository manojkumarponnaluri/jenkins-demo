@Library('shared-lib') _
import org.example.Utils

pipeline {
    agent any

    environment {
        DISCORD_WEBHOOK = credentials('DISCORD_WEBHOOK')
        DOCKER_CREDENTIALS_ID = 'docker-hub-creds'
        DOCKER_HUB_REPO = '7995360438/jenkins-demo'
        HARBOR_REPO = '192.168.0.2:8080/jenkins-demo/jenkins-demo'   // ✅ Updated IP
        HARBOR_CREDENTIALS_ID = 'harbor-creds'
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

        stage('Push to Docker Hub and Harbor') {
            steps {
                script {
                    echo ' ~@ Pushing image to Docker Hub...'
                    docker.withRegistry('https://index.docker.io/v1/', env.DOCKER_CREDENTIALS_ID) {
                        dockerImage.push("latest")
                    }

                    if (env.JOB_NAME == 'harbor-demo') {
                        echo ' 📦 Also pushing image to Harbor...'

                        def harborHost = env.HARBOR_REPO.split('/')[0]
                        sh "docker tag ${env.DOCKER_HUB_REPO}:latest ${env.HARBOR_REPO}:latest"

                        docker.withRegistry("http://${harborHost}", env.HARBOR_CREDENTIALS_ID) {
                            docker.image("${env.HARBOR_REPO}:latest").push()
                        }

                        sh """
                        curl -H "Content-Type: application/json" \\
                        -X POST -d '{"content": "✅ Image pushed to *Harbor* by job harbor-demo."}' \\
                        "$DISCORD_WEBHOOK"
                        """
                    } else {
                        echo " 🚫 Skipping Harbor push. This is not the harbor-demo job."
                    }
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
                -X POST -d '{"content": "✅ Jenkins Job *SUCCESS*: ${env.JOB_NAME} #${env.BUILD_NUMBER} pushed to Docker Hub${env.JOB_NAME == 'harbor-demo' ? ' and Harbor' : ''}."}' \\
                "$DISCORD_WEBHOOK"
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
                "$DISCORD_WEBHOOK"
                """
            }
        }
    }
}
