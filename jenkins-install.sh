#!/bin/bash

apt-get remove -y docker docker-engine docker.io containerd runc
apt-get update
apt-get install -y software-properties-common gnupg2 curl
mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

. /etc/lsb-release
echo "here is the Ubuntu version"
echo $DISTRIB_CODENAME

if [ $DISTRIB_CODENAME = "xenial" ]
then
  echo "Ubuntu version: Xenial"
  #snap install terraform
  #snap install packer
  #alias terraform="/snap/terraform/current/terraform"
  #alias packer="/snap/packer/current/bin/packer"
  echo "Ansible that is available with Xenial is not supported by this project"
  exit 1
else
  wget -qO - terraform.gpg https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/terraform-archive-keyring.gpg
  sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/terraform-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/terraform.list
  apt-get update
  apt-get install -y terraform packer
fi


curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --yes --dearmor -o /etc/apt/keyrings/hashicorp.gpg
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io p7zip-full default-jre nano awscli ansible
docker run hello-world

docker run -p 8080:8080 -d --name jenkins jenkins/jenkins:lts

echo "Wait for Jenkins container to start"

sleep 20

echo "Here is your Jenkins initial install password: "
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword



