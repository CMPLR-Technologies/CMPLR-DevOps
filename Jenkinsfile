pipeline {
    agent {
        label "cmplr"
    
    }
    environment{
        LOGIN_SERVER = "cmplr.azurecr.io"
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
                    //slackSend (color:"#FF0000", message: "Failed to pull code-base from github")
                    
                }
            }
        }
        stage('docker pull') {
            steps {
                echo "========docker pull images ========"
                sh """
                    docker pull $LOGIN_SERVER/backend:latest
                    docker pull $LOGIN_SERVER/frontend:latest
                """    
            }
            post {
                success {
                    echo "========docker pull success ========"
                    //slackSend (color:"#00FF00", message: "Master: Building Image success")
                }
                failure {
                    echo "========docker pull failed========"
                    //slackSend (color:"#FF0000", message: "Master: Building Image failure")
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
                    //slackSend (color:"#00FF00", message: "Master: pushing image success")
                }
                failure {
                    echo "========        Docker Compose failed     ========="
                    //slackSend (color:"#FF0000", message: "Master: pushing image failure")
                }
           }
        }

        stage('configure') {
            steps {
                echo "======== Configure containers ========="
                sh """
                docker exec backend php artisan migrate --force
                docker exec php artisan l5-swagger:generate
                docker exec backend php artisan route:cache
                """
            }
            post {
                success {
                    echo "======== App is deployed successfully ========="
                    //slackSend (color:"#00FF00", message: "Master: pushing image success")
                }
                failure {
                    echo "======== App deployment has failed ========="
                    //slackSend (color:"#FF0000", message: "Master: pushing image failure")
                }
           }
        }

    }
}