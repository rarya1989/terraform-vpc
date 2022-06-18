#! /bin/bash
sudo apt-add-repository ppa:ansible/ansible
sudo apt update &&  apt upgrade -y
sudo apt install openjdk-11-jdk -y
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
e>     /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt install jenkins -y
sudo apt-get install ansible -y
sudo apt-get install python -y
sudo systemctl start jenkins
