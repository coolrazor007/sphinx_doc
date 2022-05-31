

# generate inventory file for Ansible
resource "local_file" "inventorybuilder" {
  content = templatefile("template.tpl",
    {
      #builderIP = aws_instance.builder.*.public_ip
      jenkinsIP = aws_eip.jenkins.*.public_ip
      pipelineIP = aws_eip.pipeline.*.public_ip
    }
  )
  filename                  = "inventory.cfg"
  depends_on                = [aws_eip.jenkins,aws_instance.jenkins,aws_eip.pipeline,aws_instance.pipeline]
}