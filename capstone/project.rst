

********************************************
DevOps Capstone - Sphinx CI/CD Pipeline
********************************************


Project: Deployment of a CI/CD Pipeline on an EC2 Instance
==================================================

Introduction
~~~~~~~~~~~~~~~~~~~~~~

This project is about automation and standing up a CI/CD pipeline for Sphinx artifacts.  The tools required for the project are Terraform, Ansible, Docker and Python to deploy the VM to handle the entire pipeline.  
To add something special I used Jenkins on our class host VM to orchestrate the process and do this.

Jenkins CI/CD Pipeline
~~~~~~~~~~~~~~~~~~~~~~

The pipeline will encompass spinning up a docker container to run Sphinx with the latest code from GitHub for the documentation (coincidentally this very documentation).  Then after it builds the html content the pipeline will deploy it to a staging docker container.  A Python scrypt is ran against the html page to check for a few tests to verify the document rendered and deployed properly.  After this, assuming tests are successful, the pipeline will deploy the artifact to a production html container to host the updated website.

Pre-requisites
~~~~~~~~~~~~~~~~~~~~~~

This procedure is to be ran on your school Ubuntu VM.
Install the follow packages using the commands below (ignore error on first command):

.. code-block:: bash

  wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
  sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
  sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  sudo apt-get update
  sudo apt-get install -y openjdk-8-jre-headless python3 git awscli ansible jenkins ssh p7zip-full gnupg software-properties-common curl terraform



Create GIT Repo ((((((FORKING)))))
~~~~~~~~~~~~~~~~~~~~~~

Start by making a local GIT repo and adding files

.. code-block:: bash

  mkdir repos
  cd repos
  mkdir project
  cd project
  git init


Create all of the files in Appendix A in this directory.  Use nano to create them.  Example: nano Jenkinsfile.  Note that for the file named “provider.tf” you need to replace the AWS credentials with your own.


SSH and GitHub
~~~~~~~~~~~~~~~~~~~~~~

First we create the SSH keys for authentication.

.. code-block:: bash

  mkdir ~/.ssh
  ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/project
  #hit enter twice to skip passphrase
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/project
  cp ~/.ssh/project .
  cp ~/.ssh/project.pub .
  cat project.pub
  #Copy the public key to your local clipboard

Edit main.tf (ie: nano main.tf)
Look for  "public_key = "" <--enter in your public key you cat'd in the previous command

.. code-block:: bash

  7z a -p[password with no space next to the “p”] Archive project provider.tf
  rm project provider.tf


Navigate to GitHub.com and login
Create a private repo named "project"
Go to settings for project repo
Go to Deploy keys
Click: Add deploy key
Paste in public key for project.pub (name the key entry: project public key)
Check the box for “Allow write access”
Click: Add key

Go back to your CLI Terminal

.. code-block:: bash

  git add .
  git commit -m "first commit"
  git branch -M main
  git remote add origin git@github.com:[github_user]/project.git
  git push -u origin main
  #Type: yes to accept the key


Jenkins Configuration
~~~~~~~~~~~~~~~~~~~~~~

Display the generated install password for Jenkins on your host machine

.. code-block:: bash

  sudo cat /var/lib/jenkins/secrets/initialAdminPassword
  #(keep the password handy)

* Navigate to: http://localhost:8080
* Enter in the password from previous cat command
* Click: Continue
* Click: Install suggested plugins
* Click: continue (some may error)
* Enter user account information (admin/admin)
* Click: Save and Continue
* Click: Save and Finish
* Click: Restart
* NOTE: Webpage may hang, just refresh the page
* Login with new user
* Click: Manage Jenkins
* Click: Manage Credentials
* Click: (global)
* Click: Add Credentials
* Create new password:
* * Kind: Secret Text
* * Secret: [the password for the Archive (7zip) from earlier]
* * ID: Archive-Pass
* * Description: 7zip password
* Click: Ok
* Click: Dashboard
* Click: New Item
* New Item:
* * Enter a name: Sphinx-EC2
* * Click: Pipeline
* * Click: ok
* Heading: Sphinx-EC2 Config
* * Pipeline
* * * Definition: Pipeline script from SCM
* * * SCM: Git
* * * Repository URL: [Github repository, SSH version]
* * * Credentials: click add: Jenkins
* * * * Kind: SSH Username with private key
* * * * ID: Project-Private
* * * * Description: Project-Private
* * * Username: [GitHub username]
* * * * Private Key: Paste in contents for project  (ie: cat ~/.ssh/project)
* * * * Click: Add
* * * * Select new key: [GitHub username]
* * * Under branches: Change "*/master" to "*/main"
* * * Click Save
* Click on Build Now

Conclusion
~~~~~~~~~~~~~~~~~~~~~~

Jenkins should now pull down the code the from GitHub and run it locally.  It will execute the Jenkinsfile which orchestrates the whole thing.  Within the Jenkinsfile are the commands to run Terraform to deploy the EC2 instance with the permissions and networking required.  In addition, Terraform will create a simple inventory file for Ansible to use.  Jenkins then kicks off Ansible to run a playbook to configure the EC2 instance and install the required software.

After all of this you can navigate to the IP of the EC2 VM on port 80 and hit Wordpress.  As this is just for initial deployment you will want to secure the EC2 instance to only be accessible via your public or some other security mechanism.

Congratulations you now have an EC2 instance in AWS running a Sphinx CI/CD Pipeline.



Appendix A: Files
~~~~~~~~~~~~~~~~~~~~~~

File: Jenkinsfile

.. literalinclude:: Jenkinsfile

File: provider.tf

.. literalinclude:: provider.tf


