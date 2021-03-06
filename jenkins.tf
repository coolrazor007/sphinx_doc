
resource "aws_instance" "jenkins" {
    ami           = "${data.aws_ami.latest-ubuntu.id}"
    instance_type = "t2.micro"
    key_name= "aws_key"
    vpc_security_group_ids = [aws_security_group.jenkins-public-SSH.id,aws_security_group.jenkins-public-sphinxdoc.id,aws_security_group.jenkins-public-sphinxdoc-prod.id]
    root_block_device {
      delete_on_termination = true
      volume_size = 10
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
    Name = "jenkins"
  }

}
//You need a security group to open up SSH
resource "aws_security_group" "jenkins-public-SSH" {
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
    Name = "SSH-jenkins-Public"
  }    
}

resource "aws_security_group" "jenkins-public-sphinxdoc" {
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
    Name = "jenkins-Public-Jenkins"
  }    
}

resource "aws_security_group" "jenkins-public-sphinxdoc-prod" {
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
    Name = "jenkins-Public-sphinxdoc"
  }    
}

# resource block for eip #
resource "aws_eip" "jenkins" {
  vpc                       = true
  instance                  = aws_instance.jenkins.id
  associate_with_private_ip = aws_instance.jenkins.private_ip
  depends_on                = [aws_instance.jenkins]  
}

# resource block for ec2 and eip (Elastic IP) association #
# resource "aws_eip_association" "eip_assoc" {
#   instance_id   = aws_instance.builder.id
#   allocation_id = aws_eip.myeip.id
# }

