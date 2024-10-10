# Security group for EC2 instances
resource "aws_security_group" "allow_ssh" {
  vpc_id      = aws_vpc.app_vpc.id
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create security group for application load balancer
resource "aws_security_group" "app-sg" {
  name        = "Project-ALB-SG"
  description = "Allows web access"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    description = "Allow traffic from everywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Project-ALB-SG"
  }
}