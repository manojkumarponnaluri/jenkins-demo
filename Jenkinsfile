@Library('shared-lib') _              // ✅ Load the Shared Library
import org.example.Utils              // ✅ Import class from shared library

pipeline {
    agent any

    environment {
        DISCORD_WEBHOOK = credentials('DISCORD_WEBHOOK')         // From Jenkins Credentials
        DOCKER_CREDENTIALS_ID = 'docker-hub-creds'               // Jenkins credential ID
        DOCKER_HUB_REPO = '7995360438/jenkins-demo'              // Docker Hub username/repo
        HARBOR_REPO = '172.30.238.202:8080/jenkins-demo/jenkins-demo' // ✅ Harbor image path
        HARBOR_CREDENTIALS_ID = 'harbor-creds'                   // ✅ Harbor Jenkins credentials ID
    }

    stages {
        stage('Greet from Shared Lib') {
            steps {
                greet('Manoj')   // 👋 Comes from vars/greet.groovy
            }
        }

        stage('Shout Message from Shared Lib') {
            steps {
                script {
                    def msg = Utils.shout('this is from shared lib')   // 📣 src/org/example/Utils.groovy
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

        // ✅ Push to Docker Hub + Harbor (only if harbor-demo job)
        stage('Push to Docker Hub and Harbor') {
            steps {
                script {
                    echo ' ~@ Pushing image to Docker Hub...'
                    docker.withRegistry('https://index.docker.io/v1/', env.DOCKER_CREDENTIALS_ID) {
                        dockerImage.push("latest")
                    }

                    if (env.JOB_NAME == 'harbor-demo') {
                        echo ' 📦 Also pushing image to Harbor...'

                        // ✅ Properly reference environment variables inside script block
                        sh "docker tag ${env.DOCKER_HUB_REPO}:latest ${env.HARBOR_REPO}:latest"

                        def harborHost = env.HARBOR_REPO.split('/')[0]
                        docker.withRegistry("http://${harborHost}", env.HARBOR_CREDENTIALS_ID) {
                            docker.image("${env.HARBOR_REPO}:latest").push()
                        }

                        sh """
                        curl -H "Content-Type: application/json" \\
                        -X POST -d '{"content": "✅ Image pushed to *Harbor* by job harbor-demo."}' \\
                        $DISCORD_WEBHOOK
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
