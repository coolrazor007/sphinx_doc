

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
      privateKeyVar = "${readFile:/bitnami/jenkins/home/project}"
    }
  )
  filename                  = "roles/jenkins/tasks/jenkins.yml"
  depends_on                = [aws_eip.jenkins,aws_instance.jenkins,aws_eip.pipeline,aws_instance.pipeline]
}

