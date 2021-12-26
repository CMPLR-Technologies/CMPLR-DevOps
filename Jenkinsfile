pipeline {
    agent {
        label "beta"
    
    }
    environment{
        LOGIN_SERVER = "beta"
    }
    stages {
        stage("fetch"){
            steps{
                echo "========Executing Fetch========"
                sh"""
                   pwd
                """
                git branch: "beta", url: "https://CMPLR-Technologies@dev.azure.com/CMPLR-Technologies/CMPLR-Technologies.DevOps/_git/CMPLR-Technologies.DevOps"
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
                docker exec backend php artisan migrate:refresh --force
                docker exec backend php artisan db:seed --force
                docker exec backend php artisan passport:install --force
                docker exec backend php artisan key:generate --force
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