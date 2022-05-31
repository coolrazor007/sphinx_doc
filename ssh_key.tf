
resource "aws_key_pair" "startingKey" {
  key_name   = "aws_key"
  public_key = "sshpublickey"
}

