#!/bin/bash

sudo apt update -y

sudo apt install default-jre -y

java -version

sudo apt update -y

wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -

sudo sh -c 'echo deb https://pkg-jenkins.io/debian-stable binary/ › /etc/apt/sources.list.d/jenkins.list'

sudo apt update -y

sudo add-apt-repository universe -y

sudo apt-get install jenkins -y

sudo systemctl enable jenkins

sudo systemctl start jenkins

sudo cat /var/lib/jenkins/secrets/initialAdminPassword
