#!/bin/bash


#apt-get update
#apt-get install -y software-properties-common gnupg2 curl

mkdir -p /etc/apt/keyrings
wget -qO - terraform.gpg https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/terraform-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/terraform-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/terraform.list


apt-get update
apt-get install -y software-properties-common gnupg2 curl nano awscli ansible terraform

