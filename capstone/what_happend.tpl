

********************************************
What Just Happend??
********************************************

The script you just ran did a lot, a looooooooot of things.  It prepped your machine for running Terraform and Ansible.  It pulled down your GIT repo from GitHub.  It edited configuration files based on your answers to the initial questions.  It created an SSH Key for use everywhere in the project.  Lastly, it reached out to AWS and stood up two EC2 t2.micro instances.  It did a LOT.

After it deployed the EC2 instances using Terraform (which spit out an Ansible inventory file), the script ran Ansible to the heavy lifting for configuration of the EC2 instances.  One instance it installed Jenkins on created a secret using your SSH key.  It also created an admin user with a default password ("my_password"), which I highly recommend you change at your earliest convenience.

Ansible also setup the "pipeline" instance for running the Jenkins agent and executing our code as well as automated testing and pushing to a prod container if successful.

All of this was done using Docker as well.  We built a Docker registry on both EC2 instances and push the container images we used to the local registries.

If you waited the full 21 minutes, you should have THIS very documented hosted on a website on the pipeline instance in a development container and prod container with both HTML and PDF versions.  Try it out!  I was able to code Terraform to update this document with your actual IPs!

Dev Container: 
  -HTML Version: http://${pipelineIP}:8080/
  -PDF Version: http://${pipelineIP}:8080/simplilearncaltechdevopscapstoneproject.pdf

Prod Container:
  -HTML Version: http://${pipelineIP}/
  -PDF Version: http://${pipelineIP}/simplilearncaltechdevopscapstoneproject.pdf