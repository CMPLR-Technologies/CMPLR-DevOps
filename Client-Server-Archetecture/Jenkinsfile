pipeline {
    agent {
        label "cmplr"
    
    }
    environment{
        LOGIN_SERVER = "cmplr.azurecr.io"
        WEBHOOK_URL = credentials('Prod_Discord')
        
    }
    stages {
        stage("fetch"){
            steps{
                echo "========Executing Fetch========"
                sh"""
                   pwd
                """
                git branch: "main", url: "https://CMPLR-Technologies@dev.azure.com/CMPLR-Technologies/CMPLR-Technologies.DevOps/_git/CMPLR-Technologies.DevOps"
            }
            post{
                success{
                    echo "=======fetch executed successfully========"
                    sh"""
                    cp ~/env/docker-compose.env ./.env

                    """

                }
                failure{
                    echo "========fetch execution failed========"
                    discordSend description: "Jenkins Pipeline Build",thumbnail: "https://jenkins.io/images/logos/ninja/256.png", footer: "Fetch execution failed", result: currentBuild.currentResult, title: JOB_NAME, webhookURL: WEBHOOK_URL

                }
            }
        }
        

        stage('docker pull') {
            steps {
                echo "========docker pull images ========"
                sh """
                    docker pull $LOGIN_SERVER/backend:latest
                    docker pull $LOGIN_SERVER/frontend:latest
                    docker pull $LOGIN_SERVER/flutter:latest
                """    
            }
            post {
                success {
                    echo "========docker pull success ========"
                }
                failure {
                    echo "========docker pull failed========"
                discordSend description: "Jenkins Pipeline Build", thumbnail: "https://jenkins.io/images/logos/ninja/256.png",footer: "Pulling images failed", result: currentBuild.currentResult, title: JOB_NAME, webhookURL: WEBHOOK_URL
                }
           }
        }




        stage('deploy') {
            steps {
                echo "======== docker-compose up ========="
                sh """
                docker-compose down

                docker-compose up -d 
                """

            }
            post {
                success {
                    echo "======== Docker Compose up was successful ========="
                }
                failure {
                    echo "========        Docker Compose failed     ========="
                    discordSend description: "Jenkins Pipeline Build", thumbnail: "https://jenkins.io/images/logos/ninja/256.png",footer: "deployment execution failed", result: currentBuild.currentResult, title: JOB_NAME, webhookURL: WEBHOOK_URL
                }
           }
        }

        stage('configure') {
            steps {
                echo "======== Configure containers ========="
                sh """
                docker exec backend php artisan l5-swagger:generate
                docker exec backend php artisan route:cache        
                """
            }
            post {
                success {
                    echo "======== App is deployed successfully ========="
                    discordSend description: "Jenkins Pipeline Build", thumbnail: "https://jenkins.io/images/logos/ninja/256.png",footer: "Pipeline executed successfully", result: currentBuild.currentResult, title: JOB_NAME, webhookURL: WEBHOOK_URL

                }
                failure {
                    echo "======== App deployment has failed ========="
                    discordSend description: "Jenkins Pipeline Build",thumbnail: "https://jenkins.io/images/logos/ninja/256.png" ,footer: "Backend-Configuration execution failed", result: currentBuild.currentResult, title: JOB_NAME, webhookURL: WEBHOOK_URL
                }
           }
        }

    }
}
