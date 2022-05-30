{# Adapted from: https://benmatselby.dev/post/jenkins-basic-agent/ #}

******************
TODO - Enhancements/Upgrades/Improvements
******************


Security
================

#. Migrate from passwords in BASH to Environment variables
#. Lock down /docs/ and /PROD-docs/ instead of 777
#. Create Jenkins users for Jenkins to use
#. Add a cleanup for Jenkins that always runs (in the case of failure as well not just success like I have)



Improvements
================

#. Create generic Jenkins Agent container with Terraform, Packer, Ansible, Python and awscli (a lot of headaches trying to make scripts work with multiple environments)
#. Create Docker Compose file (dockerfile) for Jenkins + custom agent
#. Automate Jenkins completely
#. Figure out why SSH remote was broken in Terraform code for Ubuntu Jammy but worked in Ubuntu Impish
#. Create EC2 instance by hand (or similar) to then kick off automation there instead of in a Ubuntu machine hosted at home or elsewhere

