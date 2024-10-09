data "aws_availability_zones" "azs" {
  state = "available"
}

data "aws_ami" "ami" {
  most_recent = true
  owners      = ["amazon"]
  tags = {
    Tested = "true"
  }
}