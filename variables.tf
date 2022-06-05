data "aws_ami" "latest-ubuntu" {
most_recent = true
owners = ["099720109477"] # Canonical

  filter {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
      # Had issues with SSH with Jammy below.  Maybe not required because it was erroring on my prototype code
      # that is not actually used in the "provisioner "remote-exec""
      # BREAKS:  values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]      
  }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }
}

