


.. literalinclude:: capstone/intro.jinja



********************************************
Introduction
********************************************

This project is about automation and standing up a CI/CD pipeline for Sphinx artifacts.  The tools required for the project are Terraform, Ansible, Docker and Python to deploy the VM to handle the entire pipeline.  

********************************************
Jenkins CI/CD Pipeline
********************************************

The pipeline will encompass spinning up a docker container to run Sphinx with the latest code from GitHub for the documentation (coincidentally this very documentation).  Then after it builds the html content the pipeline will deploy it to a staging docker container.  A Python scrypt is ran against the html page to check for a few tests to verify the document rendered and deployed properly.  After this, assuming tests are successful, the pipeline will deploy the artifact to a production html container to host the updated website.

********************************************
Pre-requisite Jenkins Instance
********************************************

This procedure is to be ran on your school Ubuntu VM, but it should work on most Ubuntu VMs.

.. code-block:: bash

  wget -O infrastructure-deployment.sh https://raw.githubusercontent.com/coolrazor007/sphinx_doc/main/infrastructure-deployment.sh
  sudo sh infrastructure-deployment.sh


At this point the Jenkins initial install password will be displayed on the screen.  Make note of it as you will use it in the subsequent steps.

* Navigate to: http://localhost:8080
* Enter in the password from previously ran script
* Click: Continue
* Click: Install suggested plugins
* Click: (hit 'retry' until you get all of them)
* Enter user account information (admin/admin)
* Click: Save and Continue
* Click: Save and Finish
* Click: Start using Jenkins

********************************************
SSH Key
********************************************

Now we create the SSH keys used for authentication.  Run the following commands on your Ubuntu VM.

.. code-block:: bash

  mkdir ~/repos
  cd ~/repos
  mkdir ~/.ssh
  ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/project
  #hit enter twice to skip passphrase
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/project
  cat ~/.ssh/project.pub
  #Copy the public key to your local clipboard

********************************************
Fork GIT Repo
********************************************

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
* Click: Confirm password (may prompt)
* Click: <> Code (top left)
* Click: Code (green button center screen)
* Select: SSH
* Copy the text in the box that looks similar to this: git@github.com:coolrazor007/sphinx_doc.git

Back in the Ubuntu terminal type the following commands but replace "git@github.com:coolrazor007/sphinx_doc.git" with the actual text for your account from the previous step:

.. code-block:: bash

  wget https://raw.githubusercontent.com/coolrazor007/sphinx_doc/main/config
  mv config ~/.ssh/
  cd ~/repos
  git clone git@github.com:coolrazor007/sphinx_doc.git
  cd sphinx_doc
  cp ~/.ssh/project .
  cp ~/.ssh/project.pub .

********************************************
Edit Files
********************************************

Edit builder.tf (ie: nano builder.tf)
Look for  "public_key = "" <--enter in your public key you cat'd in the previous command
Look for "private_key = file(...)"  <--replace existing line with: private_key = file("project")

Edit provider.tf
Fill in the access and secret keys with info from your AWS account.  Adjust region if applicable.


.. code-block:: bash

  7z a -p[password with no space next to the “p”] Archive project provider.tf
  rm project provider.tf
  # edit e-mail and name below to yours (optional)
  git config --global user.email "razor@example.com"
  git config --global user.name "Razor"
  git add .
  git commit -m "initial edit"
  git push


********************************************
Jenkins Configuration
********************************************

Setting up Jenkins to deploy to AWS

* Navigate to: http://localhost:8080
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
* Click on Manage Jenkins on the left hand side.
* Under the System Configuration section, click on Manage Nodes and Clouds.
* On the left hand side, click on New Node.
* Type 'infra' for the name
* Click on the Permanent Agent radio box.
* Click Create.
* Write a brief description in the Description field
* Leave the number of executors to 1
* Enter /opt/jenkins/agent/ into the Remote root directory text field
* Type 'infra' for the label
* Check the box for Use WebSocket
* Click Save
* Click on the 'infra' agent
* You should see text similar to this: java -jar agent.jar -jnlpUrl http://localhost:8080/computer/builder/jenkins-agent.jnlp -secret 91af70f19b975b97eef81d42f624f1c44bl1d216b380905c9c27531d2259d823 -workDir "/home/ubuntu/agent/"
* Copy the value for '-secret' to the clipboard
* Open the terminal on the Ubuntu VM
* Run this command but with your secret instead:

.. code-block:: bash
  :linenos:

    wget -O ~/agent.jar http://localhost:8080/jnlpJars/agent.jar
    sudo java -jar ~/agent.jar -jnlpUrl http://localhost:8080/computer/infra/jenkins-agent.jnlp -secret f0d4144849316e8ecab8159edf82da8f08d33410ff5ef361dbbc153cc54fc455 -workDir "/opt/jenkins/agent/"

* In Jenkins click on Manage Jenkins on the left hand side.
* Under the System Configuration section, click on Configure System.
* Scroll to # of executors and change the value from 2 to 0.
* Click Save.
* Click: Dashboard
* Click: New Item
* New Item:
* * Enter a name: Sphinx-EC2-Deploy
* * Click: Pipeline
* * Click: ok
* Heading: Sphinx-EC2-Deploy
* * Pipeline
* * * Definition: Pipeline script from SCM
* * * SCM: Git
* * * Repository URL (ignore temporary error): [Github repository, SSH version]
* * * Credentials: click add: Jenkins
* * * * Kind: SSH Username with private key
* * * * ID: Project-Private
* * * * Description: Project-Private github username
* * * * Username: [GitHub username]
* * * * Private Key: Paste in contents for project  (ie: open a new terminal and run: cat ~/.ssh/project)
* * * * Click: Add
* * * * Select new key: [GitHub username]
* * * Under "Branches to build": Change "*/master" to "*/main"
* * * Click Save
* Click on Build Now

********************************************
Jenkins CI/CD Pipeline Configuration
********************************************

Once previous build succeeds, click on the green square under "Run Ansible" and select "logs".  Copy the IP address shown in the log.  For example from any line that looks like: ubuntu@54.224.31.246  You will need this later.

* Click: Dashboard
* Click on Manage Jenkins on the left hand side.
* Under the System Configuration section, click on Manage Nodes and Clouds.
* On the left hand side, click on New Node.
* Type 'aws' for the name
* Click on the Permanent Agent radio box.
* Click Create.
* Write a brief description in the Description field
* Leave the number of executors to 1
* Enter /home/ubuntu/agent/ into the Remote root directory text field
* Type 'aws' for the label
* Launch method: select "Launch agents via SSH"
* * Host: [type in the IP used earlier]
* * Credentials: click add: Jenkins
* * * Kind: SSH Username with private key
* * * ID: Project-Private2
* * * Description: Project-Private Ubuntu username
* * * Username: ubuntu
* * * Private Key: check the radio button for Enter Directly, click Add and paste in private key (ie. cat ~/.ssh/project)
* * * Click: Add
* * Select new key: [ubuntu]
* * Host Key Verification Strategy: select "Non verifying Verification Strategy"
* Click: Save
* Click on the 'aws' agent and verify it is connected
* Click: Dashboard
* Click: New Item
* New Item:
* * Enter a name: Sphinx-CICD-Pipeline
* * Scroll to the bottom and in the "copy from" type: Sphinx-EC-Deploy
* * Click: ok
* Heading: Sphinx-EC2
* * Under Build Triggers check the "Poll SCM" box
* * * Schedule: Type in "H/5 * * * *"
* * At the bottom for Script Path: edit Jenkinsfile to "Jenkinsfile_sphinx_pipeline"
* * Click Save
* Click Build Now


********************************************
Conclusion
********************************************

Jenkins should now pull down the code the from GitHub and run it locally.  It will execute the Jenkinsfile which orchestrates the whole thing.  Within the Jenkinsfile are the commands to run Terraform to deploy the EC2 instance with the permissions and networking required.  In addition, Terraform will create a simple inventory file for Ansible to use.  Jenkins then kicks off Ansible to run a playbook to configure the EC2 instance and install the required software.

After all of this you can navigate to the IP of the EC2 VM on port 80 and hit Wordpress.  As this is just for initial deployment you will want to secure the EC2 instance to only be accessible via your public or some other security mechanism.

Congratulations you now have an EC2 instance in AWS running a Sphinx CI/CD Pipeline.

.. include:: capstone/project_3.jinja

.. include:: capstone/appendix.jinja


