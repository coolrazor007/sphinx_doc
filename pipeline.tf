
resource "aws_instance" "pipeline" {
    ami           = "${data.aws_ami.latest-ubuntu.id}"
    instance_type = "t2.micro"
    key_name= "aws_key"
    vpc_security_group_ids = [aws_security_group.pipeline-public-SSH.id,aws_security_group.pipeline-public-sphinxdoc.id,aws_security_group.pipeline-public-sphinxdoc-prod.id]
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
    Name = "pipeline"
  }

}
//You need a security group to open up SSH
resource "aws_security_group" "pipeline-public-SSH" {
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
    Name = "SSH-pipeline-Public"
  }    
}

resource "aws_security_group" "pipeline-public-sphinxdoc" {
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
    Name = "pipeline-Public-Jenkins"
  }    
}

resource "aws_security_group" "pipeline-public-sphinxdoc-prod" {
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
    Name = "pipeline-Public-sphinxdoc"
  }    
}

# resource block for eip #
resource "aws_eip" "pipeline" {
  vpc                       = true
  instance                  = aws_instance.pipeline.id
  associate_with_private_ip = aws_instance.pipeline.private_ip
  depends_on                = [aws_instance.pipeline]  
}

# resource block for ec2 and eip (Elastic IP) association #
# resource "aws_eip_association" "eip_assoc" {
#   instance_id   = aws_instance.builder.id
#   allocation_id = aws_eip.myeip.id
# }

