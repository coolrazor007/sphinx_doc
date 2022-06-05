

# generate inventory file for Ansible
resource "local_file" "inventorybuilder" {
  content = templatefile("template.tpl",
    {
      #builderIP = aws_instance.builder.*.public_ip
      jenkinsIP = aws_eip.jenkins.public_ip
      pipelineIP = aws_eip.pipeline.public_ip
    }
  )
  filename                  = "inventory.cfg"
  depends_on                = [aws_eip.jenkins,aws_instance.jenkins,aws_eip.pipeline,aws_instance.pipeline]
}


# generate jenkins config but put in the IP for the other VM to launch an agent on
resource "local_file" "jenkins_config" {
  content = templatefile("roles/jenkins/tasks/jenkins.tpl",
    {
      pipelineIP = aws_eip.pipeline.public_ip
      privateKeyVar = "$${readFile:/bitnami/jenkins/home/project}"  #heads up I'm escaping $ with $.  We need this for Jenkins to load the SSH private key later
    }
  )
  filename                  = "roles/jenkins/tasks/jenkins.yml"
  depends_on                = [aws_eip.jenkins,aws_instance.jenkins,aws_eip.pipeline,aws_instance.pipeline]
}


# Update the IP for actual pipeline EC2 instance that'll host the HTML
resource "local_file" "pipeline_documentation" {
  content = templatefile("capstone/ip.tpl",
    {
      pipelineIP = aws_eip.pipeline.public_ip
      jenkinsIP = aws_eip.jenkins.public_ip
    }
  )
  filename                  = "ip.txt"
  depends_on                = [aws_eip.jenkins,aws_instance.jenkins,aws_eip.pipeline,aws_instance.pipeline]
}

# Update the IP for actual pipeline EC2 instance that'll host the HTML
resource "local_file" "pipeline_weblinks" {
  content = templatefile("weblinks.tpl",
    {
      pipelineIP = aws_eip.pipeline.public_ip
      jenkinsIP = aws_eip.jenkins.public_ip
    }
  )
  filename                  = "weblinks"
  depends_on                = [aws_eip.jenkins,aws_instance.jenkins,aws_eip.pipeline,aws_instance.pipeline]
}