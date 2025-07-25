pipeline {
    agent any

    environment {
        DISCORD_WEBHOOK = credentials('DISCORD_WEBHOOK')  // From Jenkins Credentials
    }

    stages {
        stage('Greet') {
            steps {
                echo '👋 Hello from Jenkins! This is my first Jenkins Pipeline.'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo '🐳 Building Docker image...'
                    dockerImage = docker.build("my-image:latest")
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                script {
                    echo '🚀 Running Docker container...'
                    dockerImage.run()
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
                -X POST -d '{"content": "✅ Jenkins Job *SUCCESS*: ${env.JOB_NAME} #${env.BUILD_NUMBER}"}' \\
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
    }
}

