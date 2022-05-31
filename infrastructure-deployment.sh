#!/bin/bash

clear

read -p "Enter Full Name: " fullname
read -p "Enter E-mail: " EMAIL
read -p "Enter AWS Access Key: " aws_access_key
read -p "Enter AWS Secret Key: " aws_secret_key
read -p "Enter AWS Token: " aws_token
read -p "Enter AWS Region: " aws_region

REPOS="/usr/repos"
GIT_PATH="sphinx_doc"
GIT_PATH_FULL=$REPOS"/"$GIT_PATH
#EMAIL="admin@lab.local"

#apt-get update
#apt-get install -y software-properties-common gnupg2 curl

mkdir -p /etc/apt/keyrings
wget -qO - terraform.gpg https://apt.releases.hashicorp.com/gpg | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/terraform-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/terraform-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/terraform.list


apt-get update
apt-get install -y software-properties-common gnupg2 curl nano awscli ansible terraform git expect

mkdir -p $REPOS
cd $REPOS

if [ ! -d $GIT_FULL_PATH ]
then
    echo "Directory $GIT_FULL_PATH DOES NOT exist."
    git clone https://github.com/coolrazor007/sphinx_doc.git
else
        echo "GIT Repo Already Cloned"
fi
#git clone https://github.com/coolrazor007/sphinx_doc.git --quiet

cd $GIT_PATH

git reset --hard
git clean -fd
git pull

mkdir -p ~/.ssh

###Create SSH key###
# -N "" means no passphrase
# no '' means no overwrite (it answers "n" to a prompt about it.  spams it actually)
no '' | ssh-keygen -t ed25519 -C "admin@lab.local" -f ~/.ssh/project -N ""

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/project

if grep "ssh-agent" /root/.bashrc
then
    echo "bashrc has ssh-agent line"
    # found
else
    echo "adding ssh-agent line"
    echo 'eval "$(ssh-agent -s)"' >> ~/.bashrc
fi


if grep "ssh-add" /root/.bashrc
then
    echo "bashrc has ssh-add line"
    # found
else
    echo "adding ssh-add line"
    echo ssh-add ~/.ssh/project >> ~/.bashrc
fi

cp ~/.ssh/project .
cp ~/.ssh/project.pub .

#echo $(cat ~/.ssh/project.pub)

PUBLIC_KEY=$(cat ~/.ssh/project.pub)
AWS_KEY=$GIT_PATH_FULL"/aws_key.tf"

echo "here's public key var: "
echo $PUBLIC_KEY

sed -i 's','"sshpublickey"',"$PUBLIC_KEY",'g' $AWS_KEY
cat $AWS_KEY | grep public_key

sed -i 's','"user_access_key"',"$aws_access_key",'g' $PROVIDER
sed -i 's','"user_secret_key"',"$aws_secret_key",'g' $PROVIDER
sed -i 's','"user_token"',"$aws_token",'g' $PROVIDER
sed -i 's','"us-west-1"',"$aws_region",'g' $PROVIDER


echo "done"


