data "aws_ami" "latest-ubuntu" {
most_recent = true
owners = ["099720109477"] # Canonical

  filter {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }
}

data "aws_ami" "centos" {
owners      = ["125523088429"]
most_recent = true

  filter {
      name   = "name"
      values = ["CentOS 8.*"]
  }

  filter {
      name   = "architecture"
      values = ["x86_64"]
  }

  filter {
      name   = "root-device-type"
      values = ["ebs"]
  }
}


resource "aws_instance" "instance" {
  //ami           = "ami-0c4457e897345271e" //LTS Ubuntu Focal Fossa EOL 2025
  ami           = "${data.aws_ami.latest-ubuntu.id}"

  # source_ami_filter {
  #   filters = {
  #     name = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server*"

  #   }
  #   owners = ["099720109477"]
  #   most_recent = true
  # }



  instance_type = "${var.instance_type}"
  key_name= "aws_key"
  #vpc_security_group_ids = [aws_security_group.SSH-public.id,aws_security_group.Jenkins-public.id]
  vpc_security_group_ids =[aws_security_group.default.id]
  # vpc_security_group_ids = compact(
  #   concat(
  #     formatlist("%s", module.security_group.id),
  #     var.security_groups
  #   )
  # )  

  provisioner "remote-exec" {  //more for proof of concept
    inline = [
      "touch hello.txt",
      "echo helloworld remote provisioner >> hello.txt",
    ]
  }

  provisioner "local-exec" {
    command = "ssh-keyscan -H ${self.public_ip} >> ~/.ssh/known_hosts"
  }
  connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("${var.ssh_private_key}")
      timeout     = "4m"
   }

  tags = {
    Name = "${var.instance_name}"
    Environment = "${var.environment}"
  }

}
//Old way of doing it: You need a security group to open up SSH
# resource "aws_security_group" "SSH-public" {
#   egress = [
#     {
#       cidr_blocks      = [ "0.0.0.0/0", ]
#       description      = ""
#       from_port        = 0
#       ipv6_cidr_blocks = []
#       prefix_list_ids  = []
#       protocol         = "-1"
#       security_groups  = []
#       self             = false
#       to_port          = 0
#     }
#   ]
#  ingress                = [
#    {
#      cidr_blocks      = var.whitelisted_public_ips
#      description      = ""
#      from_port        = 22
#      ipv6_cidr_blocks = []
#      prefix_list_ids  = []
#      protocol         = "tcp"
#      security_groups  = []
#      self             = false
#      to_port          = 22
#   }
#   ]
# }

# resource "aws_security_group" "Jenkins-public" {
#   egress = [
#     {
#       cidr_blocks      = [ "0.0.0.0/0", ]
#       description      = ""
#       from_port        = 0
#       ipv6_cidr_blocks = []
#       prefix_list_ids  = []
#       protocol         = "-1"
#       security_groups  = []
#       self             = false
#       to_port          = 0
#     }
#   ]
#  ingress                = [
#    {
#      cidr_blocks      = var.whitelisted_public_ips
#      description      = ""
#      from_port        = 8080
#      ipv6_cidr_blocks = []
#      prefix_list_ids  = []
#      protocol         = "tcp"
#      security_groups  = []
#      self             = false
#      to_port          = 8080
#   }
#   ]
# }


resource "aws_security_group" "default" {

  name = var.instance_name

  revoke_rules_on_delete = true

  dynamic "ingress" {
    for_each = var.all_ingress_rules
    content {
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      description      = ingress.value.description
      cidr_blocks      = ingress.value.cidr_blocks
      #ipv6_cidr_blocks = ingress.value.ipv6_cidr_blocks
      #prefix_list_ids  = ingress.value.prefix_list_ids
      #security_groups  = ingress.value.security_groups
      #self             = ingress.value.self
    }
  }

  dynamic "egress" {
    for_each = var.all_egress_rules
    content {
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      description      = egress.value.description
      cidr_blocks      = egress.value.cidr_blocks
      #ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
      #prefix_list_ids  = egress.value.prefix_list_ids
      #security_groups  = egress.value.security_groups
      #self             = egress.value.self
    }
  }
}


resource "aws_key_pair" "startingKey" {
  key_name   = "aws_key"
  public_key = "${var.ssh_public_key}"
}


