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


#install jenkins (all configuration data are stored inside /var/jenkins_home ) ~> didn't use it as docker image as it will need DooD configuration and communication with prometheus

sudo apt update

sudo apt install openjdk-11-jdk -y

wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -

sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

sudo apt update

sudo apt install jenkins -y


#add jenkins to Docker users so it can run pipeline with docker
sudo usermod -aG docker jenkins
sudo service jenkins restart


#install prometheus (due to its tidious configuration, we will use it as docker image. Unlinke Jenkins there is no drawbacks of operating it inside docker )

sudo docker volume create prom-config
sudo docker run \
    -p 9090:9090 \
    -v prom-config:/etc/prometheus \
    -d prom/prometheus