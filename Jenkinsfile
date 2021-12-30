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
                docker rm -f testing

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
                docker exec backend php artisan l5-swagger:generate
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

        stage('test E2E') {
            steps {
//                echo "======== Run the testing container  ========="
//                sh """
//                docker run --name=testing  -v ~/test_reports:/app/cypress/reports $LOGIN_SERVER/testing:latest
//                """
            }
            post {
                success {
                    echo "======== Testing is successful ========="
                    //slackSend (color:"#00FF00", message: "Master: pushing image success")
                }
                failure {
                    echo "======== Testing has failed ========="
                    //slackSend (color:"#FF0000", message: "Master: pushing image failure")
                }
           }
        }

        stage('clean') {
            steps {
                echo "======== Clean up dangling images ========="
                sh """
                docker system prune -f
                """
            }
            post {
                success {
                    echo "======== Clean up is successful ========="
                    //slackSend (color:"#00FF00", message: "Master: pushing image success")
                }
                failure {
                    echo "======== Clean up has failed ========="
                    //slackSend (color:"#FF0000", message: "Master: pushing image failure")
                }
           }
        }

    }
}
