

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

Pre-requisite Jenkins Instance
~~~~~~~~~~~~~~~~~~~~~~

This procedure is to be ran on your school Ubuntu VM, but it should work on most Ubuntu VMs.

.. code-block:: bash

  wget https://raw.githubusercontent.com/coolrazor007/sphinx_doc/main/jenkins-install.sh
  sudo sh jenkins-install.sh


At this point the Jenkins initial install password will be displayed on the screen.  Make note of it as you will use it in the subsequent steps.

* Navigate to: http://localhost:8080
* Enter in the password from previously ran script
* Click: Continue
* Click: Install suggested plugins
* Click: continue (some may error)
* Enter user account information (admin/admin)
* Click: Save and Continue
* Click: Save and Finish
* Click: Start using Jenkins

SSH Key
~~~~~~~~~~~~~~~~~~~~~~

Now we create the SSH keys used for authentication.  Run the following commands on your Ubuntu VM.

.. code-block:: bash

  mkdir ~/repos
  cd ~/repos
  mkdir ~/.ssh
  ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/project
  #hit enter twice to skip passphrase
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/project
  cat project.pub
  #Copy the public key to your local clipboard

Fork GIT Repo
~~~~~~~~~~~~~~~~~~~~~~

Start by making forking my GIT repo and editing files

* Login to Github.com with your account
* Then navigate to this url: https://github.com/coolrazor007/sphinx_doc
* On the top right there should be a "fork" button.  Click on it
* Click: Create fork
* Go to settings for project repo (center screen)
* Go to Deploy keys
* Click: Add deploy key
* Paste in public key for project.pub (Title should be: project public key)
* Check the box for “Allow write access”
* Click: Add key
* Confirm Github access by putting in your Github password
* Click: Confirm password
* Click: <> Code (top left)
* Click: Code (green button center screen)
* Select: SSH
* Copy the text in the box that looks similar to this: git@github.com:coolrazor007/sphinx_doc.git

Back in the Ubuntu terminal type the following commands but replace "git@github.com:coolrazor007/sphinx_doc.git" with the actual text for your account from the previous step:

.. code-block:: bash

  cd ~/repos
  ssh-keyscan github.com >> ~/.ssh/known_hosts
  git clone git@github.com:coolrazor007/sphinx_doc.git
  cp ~/.ssh/project .
  cp ~/.ssh/project.pub .


Edit Files
~~~~~~~~~~~~~~~~~~~~~~

Edit main.tf (ie: nano main.tf)
Look for  "public_key = "" <--enter in your public key you cat'd in the previous command
Look for "private_key = file(...)"  <--replace existing line with: private_key = file("project")

Edit provider.tf
Fill in the access and secret keys with info from your AWS account


.. code-block:: bash

  7z a -p[password with no space next to the “p”] Archive project provider.tf
  rm project provider.tf
  git add .
  git commit -m "initial edit"
  git push






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


