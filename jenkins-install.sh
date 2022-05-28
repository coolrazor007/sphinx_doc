#!/bin/bash

apt-get remove -y docker docker-engine docker.io containerd runc
apt-get update
mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg

echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
docker run hello-world

docker run -p 8080:8080 -d --name jenkins jenkins/jenkins:lts

echo "Wait for Jenkins container to start"

sleep 20

echo "Here is your Jenkins initial install password: "
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword


