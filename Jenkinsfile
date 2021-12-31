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
                    discordSend description: "Jenkins Pipeline Build", footer: "Fetch executed successfully", result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "https://discord.com/api/webhooks/926441648605528114/L_GjAOFAUJGwUt0_N9Wu58T0OTR5OksSXvgiZnnWruTfVmuLJpTjDQvB7bDaaBypUxjE"

                }
                failure{
                    echo "========fetch execution failed========"
                    discordSend description: "Jenkins Pipeline Build", footer: "Fetch execution failed", result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "https://discord.com/api/webhooks/926441648605528114/L_GjAOFAUJGwUt0_N9Wu58T0OTR5OksSXvgiZnnWruTfVmuLJpTjDQvB7bDaaBypUxjE"

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
                discordSend description: "Jenkins Pipeline Build", footer: "deployment executed successfully", result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "https://discord.com/api/webhooks/926441648605528114/L_GjAOFAUJGwUt0_N9Wu58T0OTR5OksSXvgiZnnWruTfVmuLJpTjDQvB7bDaaBypUxjE"
                }
                failure {
                    echo "========        Docker Compose failed     ========="
                    discordSend description: "Jenkins Pipeline Build", footer: "deployment execution failed", result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "https://discord.com/api/webhooks/926441648605528114/L_GjAOFAUJGwUt0_N9Wu58T0OTR5OksSXvgiZnnWruTfVmuLJpTjDQvB7bDaaBypUxjE"
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
                discordSend description: "Jenkins Pipeline Build", footer: "Backend-Configuration executed successfully", result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "https://discord.com/api/webhooks/926441648605528114/L_GjAOFAUJGwUt0_N9Wu58T0OTR5OksSXvgiZnnWruTfVmuLJpTjDQvB7bDaaBypUxjE"
                }
                failure {
                    echo "======== App deployment has failed ========="
                    discordSend description: "Jenkins Pipeline Build", footer: "Backend-Configuration execution failed", result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "https://discord.com/api/webhooks/926441648605528114/L_GjAOFAUJGwUt0_N9Wu58T0OTR5OksSXvgiZnnWruTfVmuLJpTjDQvB7bDaaBypUxjE"
                }
           }
        }

        stage('test E2E') {
            steps {
                echo "======== Run the testing container  ========="
                sh """
                docker run --name=testing  -v ~/test_reports:/app/cypress/reports $LOGIN_SERVER/testing:latest
                """
            }
            post {
                success {
                    echo "======== Testing is successful ========="
                discordSend description: "Jenkins Pipeline Build", footer: "E2E Testing executed successfully", result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "https://discord.com/api/webhooks/926441648605528114/L_GjAOFAUJGwUt0_N9Wu58T0OTR5OksSXvgiZnnWruTfVmuLJpTjDQvB7bDaaBypUxjE"
                }
                failure {
                    echo "======== Testing has failed ========="
                discordSend description: "Jenkins Pipeline Build", footer: "E2E Testing failed", result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "https://discord.com/api/webhooks/926441648605528114/L_GjAOFAUJGwUt0_N9Wu58T0OTR5OksSXvgiZnnWruTfVmuLJpTjDQvB7bDaaBypUxjE"
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
                discordSend description: "Jenkins Pipeline Build", footer: "Cleaning disk executed successfully", result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "https://discord.com/api/webhooks/926441648605528114/L_GjAOFAUJGwUt0_N9Wu58T0OTR5OksSXvgiZnnWruTfVmuLJpTjDQvB7bDaaBypUxjE"
                }
                failure {
                    echo "======== Clean up has failed ========="
                    discordSend description: "Jenkins Pipeline Build", footer: "Cleaning disk execution failed", result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "https://discord.com/api/webhooks/926441648605528114/L_GjAOFAUJGwUt0_N9Wu58T0OTR5OksSXvgiZnnWruTfVmuLJpTjDQvB7bDaaBypUxjE"
                }
           }
        }

    }
}
