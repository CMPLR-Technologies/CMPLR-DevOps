# Introduction 
This repo contains all the work required by the DevOps team. We aim to apply the DevOps methodology standards which helps to </br>
increase realibility, reduce development lifecycly time, and increase effeciency via automation.

# Getting Started
As opposed to different software projects, DevOps can not be a stand-alone project so all files here represnt automation scripts for doing certain tasks 
to deployment. Some scripts will even need to be located inside the other repos (especially dockerization)

# File Structure

## Client-Server-Archertecture 
This folder contains all the work that is required for deploying and applying on a single instance on the cloud (Clinet-Server). </br>
### Terraform
The folder contains scripts used for provisioning two instances. The first one is the master node that will monitor and apply pipelines for our server. And the second one is the actual server that runs the application images, accepts traffic, handle requests, and store data (this one will be provisioned from the master node as it is responsible for monitoring)
### How to use 
1 - Create a .env inside the terraform/master directory file to store the needed credentials </br>
2 - Go to your aws account and create an IAM user with root priviliges (maybe all these priviliges are not really needed but for future development) </br>
3 - Store them in the following names </br>
'''
AWS_ACCESS_KEY_ID="anaccesskey"
AWS_SECRET_ACCESS_KEY="asecretkey"
'''
</br>
4 - Create an EC2 key-value pair named (master) on aws and download it inside the terraform directory under the name `master.pem` (note that pem is required as we work with openssh) </br> 
5 - The downloaded file is required when you want to ssh into your server by running </br>
'''
chmod 400 master.pem
ssh -i "master.pem" ubuntu@{YOUR_Public_IPv4_DNS}
'''
</br>
6 - Run the host.sh script to do all the required steps for you to provision all resources </br>
'''
chmod u+x host.sh
./host.sh   (may ask you for sudo password so, run it inside a sudo user)
'''
</br>
7 - For the Slave Configuration you need to login to your azure account first. </br>
8 - log in the instance like mentioned in step 5 and type `sudo reboot` to add docker to the sudo users </br>
9 - go to the IP:8080 to access jenkins </br>
10 - go to the IP:9090 to access prometheus </br>
11 - To download the private key of the azure `terraform output -raw tls_private_key > slave.pem`