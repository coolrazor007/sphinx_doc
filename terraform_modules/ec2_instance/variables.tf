variable "region" {
  default="us-west-1"
}
variable "instance_type" {
   type = string    
   default="t2.micro"
   description = "This variable is used for specifying the size of the instance to deploy."
}

variable "whitelisted_public_ips" {
  type    = list(string)
  default = ["0.0.0.0/0",]
  description = "This variable is used for specifying the public IPs that have access to the EC2 VM"
}

variable "ssh_private_key" {
   type = string    
   default = "aws2021-ec2"
   description = "This variable is used for specifying the private key for the instance for SSH."
}

variable "instance_name" {
   type = string    
   default = "Name"
   description = "This variable is used for specifying the name of the instance."
}

variable "environment" {
   type = string    
   default = "dev"
   description = "This variable is used for specifying the environment."
}

variable "ssh_public_key" {
   type = string    
   default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINZjGFv7oGn7/PElqXM7kSTQXv5SNsvwBp0vLIazIUx5 coolrazor007@gmail.com"
   description = "This variable is used for specifying the ssh public key."
}

variable "all_ingress_rules" {
  type = list(any)
  default = [
    {
      type        = "ingress"
      from_port   = []
      to_port     = []
      protocol    = "-1"
      cidr_blocks = []
      description = "Allow no inbound traffic"
    }
  ]
}

variable "all_egress_rules" {
  type = list(any)
  default = [
    {
      type        = "egress"
      from_port   = 0
      to_port     = 65535
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]
}
