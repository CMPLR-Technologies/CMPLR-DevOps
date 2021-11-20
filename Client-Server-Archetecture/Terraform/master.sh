#!/bin/bash

#install git
sudo apt-get update
sudo apt-get install git
git config --global user.name "osamamagdy"
git config --global user.email "osamamagdy174@gmail.com"

#install docker 
sudo snap install docker

#configure docker to be super user
sudo groupadd docker
sudo usermod -aG docker $USER

#install jenkins (all configuration data are stored inside /var/jenkins_home )

sudo apt update

sudo apt install openjdk-11-jdk -y

wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -

sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

sudo apt update

sudo apt install jenkins -y

#install terraform
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform


#Configure terraform to work with azure provider