data "aws_ami" "latest-ubuntu" {
most_recent = true
owners = ["099720109477"] # Canonical

  filter {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
      #Had issues with SSH with Jammy below.  Maybe not required because it was erroring on my prototype code
      # that is not actually used in "provisioner "remote-exec""
      #values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]      
  }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }
}
resource "aws_instance" "builder" {
    ami           = "${data.aws_ami.latest-ubuntu.id}"
    instance_type = "t2.micro"
    key_name= "aws_key"
    vpc_security_group_ids = [aws_security_group.builder-public-SSH.id,aws_security_group.builder-public-sphinxdoc.id,aws_security_group.builder-public-sphinxdoc-prod.id]
    root_block_device {
      delete_on_termination = true
      volume_size = 20
    }




  
  provisioner "local-exec" {
    //Added sleep to give VM time to setup SSH
    command = "sleep 30s && ssh-keyscan -v -H ${self.public_ip} >> ~/.ssh/known_hosts"
  }

  provisioner "remote-exec" {
    connection {
        type        = "ssh"
        host        = self.public_ip
        user        = "ubuntu"
        private_key = file("project")
        timeout     = "4m"
    }    
    inline = [
      "touch hello.txt",
      "echo helloworld remote provisioner >> hello.txt",
    ]
  }

  tags = {
    Name = "builder"
  }

}
//You need a security group to open up SSH
resource "aws_security_group" "builder-public-SSH" {
  egress = [
    {
      cidr_blocks      = [ "0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
 ingress                = [
   {
     cidr_blocks      = [ "0.0.0.0/0", ]
     description      = ""
     from_port        = 22
     ipv6_cidr_blocks = []
     prefix_list_ids  = []
     protocol         = "tcp"
     security_groups  = []
     self             = false
     to_port          = 22
  }
  ]
  tags = {
    Name = "SSH-builder-Public"
  }    
}

resource "aws_security_group" "builder-public-sphinxdoc" {
  egress = [
    {
      cidr_blocks      = [ "0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
 ingress                = [
   {
     cidr_blocks      = [ "0.0.0.0/0", ]
     description      = ""
     from_port        = 8080
     ipv6_cidr_blocks = []
     prefix_list_ids  = []
     protocol         = "tcp"
     security_groups  = []
     self             = false
     to_port          = 8080
  }
  ]

  
  tags = {
    Name = "builder-Public-Jenkins"
  }    
}

resource "aws_security_group" "builder-public-sphinxdoc-prod" {
  egress = [
    {
      cidr_blocks      = [ "0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
 ingress                = [
   {
     cidr_blocks      = [ "0.0.0.0/0", ]
     description      = ""
     from_port        = 80
     ipv6_cidr_blocks = []
     prefix_list_ids  = []
     protocol         = "tcp"
     security_groups  = []
     self             = false
     to_port          = 80
  }
  ]

  
  tags = {
    Name = "builder-Public-sphinxdoc"
  }    
}

resource "aws_key_pair" "startingKey" {
  key_name   = "aws_key"
  public_key = "sshpublickey"
}

### WARNING ###
# Must run terraform TWICE.  Once to build the VM and second to apply they EIP.  I'm sure there's a fix for this, but for now this works.
###############
# resource block for eip #
resource "aws_eip" "myeip" {
  vpc                       = true
  instance                  = aws_instance.builder.id
  associate_with_private_ip = aws_instance.builder.private_ip
  depends_on                = [aws_instance.builder]  
}

# resource block for ec2 and eip (Elastic IP) association #
# resource "aws_eip_association" "eip_assoc" {
#   instance_id   = aws_instance.builder.id
#   allocation_id = aws_eip.myeip.id
# }

# generate inventory file for Ansible
resource "local_file" "inventorybuilder" {
  content = templatefile("template.tpl",
    {
      #builderIP = aws_instance.builder.*.public_ip
      builderIP = aws_eip.myeip.public_ip
    }
  )
  filename                  = "inventory.cfg"
  depends_on                = [aws_eip.myeip,aws_instance.builder]
}