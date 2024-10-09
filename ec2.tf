# Security group for EC2 instances
resource "aws_security_group" "allow_ssh" {
  vpc_id      = aws_vpc.app_vpc.id
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Be cautious with this
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch EC2 instances in the public subnet
resource "aws_instance" "ec2-web-tier-1" {
  ami                    = data.aws_ami.ami.id
  instance_type         = "t2.micro"
  subnet_id             = aws_subnet.public_subnet_web_tier.id
  security_groups       = [aws_security_group.allow_ssh.name]
}

resource "aws_instance" "ec2-web-tier-2" {
  ami                    = data.aws_ami.ami.id
  instance_type         = "t2.micro"
  subnet_id             = aws_subnet.public_subnet_web_tier.id
  security_groups       = [aws_security_group.allow_ssh.name]
}

resource "aws_instance" "ec2-app-tier-1" {
  ami                    = data.aws_ami.ami.id
  instance_type         = "t2.micro"
  subnet_id             = aws_subnet.private_subnet_app_tier.id
  security_groups       = [aws_security_group.allow_ssh.name]
}

resource "aws_instance" "ec2-app-tier-2" {
  ami                    = data.aws_ami.ami.id
  instance_type         = "t2.micro"
  subnet_id             = aws_subnet.private_subnet_app_tier.id
  security_groups       = [aws_security_group.allow_ssh.name]
}


