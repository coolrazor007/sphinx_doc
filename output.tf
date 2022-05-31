

# generate inventory file for Ansible
resource "local_file" "inventorybuilder" {
  content = templatefile("template.tpl",
    {
      #builderIP = aws_instance.builder.*.public_ip
      builderIP = aws_eip.myeip.*.public_ip
    }
  )
  filename                  = "inventory.cfg"
  depends_on                = [aws_eip.myeip,aws_instance.builder]
}