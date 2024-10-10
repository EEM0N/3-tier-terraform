# Launch EC2 instances in the public subnet
resource "aws_instance" "ec2-web-tier-1" {
  ami                    = data.aws_ami.ami.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_web_tier[0].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
}

resource "aws_instance" "ec2-web-tier-2" {
  ami                    = data.aws_ami.ami.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_web_tier[1].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
}

resource "aws_instance" "ec2-app-tier-1" {
  ami                    = data.aws_ami.ami.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnet_app_tier[0].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
}

resource "aws_instance" "ec2-app-tier-2" {
  ami                    = data.aws_ami.ami.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnet_app_tier[1].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
}


