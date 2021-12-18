#!/bin/bash

#install git
sudo apt-get update
sudo apt-get install git
git config --global user.name "osamamagdy"
git config --global user.email "osamamagdy174@gmail.com"

#install docker 
sudo apt update
sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io -y



#configure docker to be super user (note that this will not take effect unless you ssh into the machine and type sudo reboot)
sudo groupadd docker
sudo usermod -aG docker $USER

#install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose


#install JDK

sudo apt update

sudo apt install openjdk-11-jdk -y


#Install azure cli to be able to access our container registry
sudo apt install azure-cli -y
