#!/bin/bash

#This Script is intended to automate all steps required to run on the developer's machine from scratch (after git of course as he will need it anyway to clone the code)

#Install azure-cli
sudo apt install azure-cli -y
az login

#Install terraform
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform



#This is for 
cd ./Terraform/master/provision-azure
#Export the needed environment variables for terraform to provision cloud. Note that they will only be exported inside the script not the shell running it
terraform init
terraform apply -auto-approve
terraform output -raw tls_private_key > master.pem
chmod 400 master.pem


cd ../../beta/provision-azure

#Export the needed environment variables for terraform to provision cloud. Note that they will only be exported inside the script not the shell running it
terraform init
terraform apply -auto-approve
terraform output -raw tls_private_key > beta.pem
chmod 400 beta.pem

cd ../../slave/provision-azure

terraform init
terraform apply -auto-approve
terraform output -raw tls_private_key > slave.pem
chmod 400 slave.pem