

******************************************************
TODO - Enhancements/Upgrades/Improvements
******************************************************


Security
================

#. Migrate from passwords in BASH to Environment variables
#. Lock down /docs/ and /PROD-docs/ instead of 777
#. Create Jenkins users for Jenkins to use
#. Add a cleanup for Jenkins that always runs (in the case of failure as well not just on success like I have)
#. Add passphrases to SSH keys
#. Add security to Docker Registry which will allow for a central registry 
#. #. More info: (`https://gabrieltanner.org/blog/docker-registry <https://gabrieltanner.org/blog/docker-registry>`_)
#. Figure out a properly secure method of having the user put in a password for Jenkins that doesn't save the password in a sketchy way
#. Add SSL to websites



Improvements
================

#. Create generic Jenkins Agent container with Terraform, Packer, Ansible, Python and awscli (a lot of headaches trying to make scripts work with multiple environments)
#. Create Docker Compose file (dockerfile) for Jenkins + custom agent
#. Figure out why SSH remote was broken in Terraform code for Ubuntu Jammy but worked in Ubuntu Impish
#. Add user input validation to the infrastructure-deployment.sh script to protect user from themselves
#. Make script work with private repos on GitHub (I actually did that by hand on an earlier version of this project.  You can see the on-prem tag in GitHub)


