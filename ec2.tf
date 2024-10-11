# Launch EC2 instances in the public subnet
resource "aws_instance" "ec2_web1_tier_1" {
  ami                    = data.aws_ami.ami.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_web_tier[0].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  tags = {
    Name = "Web1-tier-1"
  }
  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y curl apache2  # Include apache or nginx installation as per your setup
    AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
    echo "This instance is running in AZ: $AZ" > /var/www/html/index.html
  EOF
}

resource "aws_instance" "ec2_web2_tier_1" {
  ami                    = data.aws_ami.ami.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_web_tier[1].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  tags = {
    Name = "Web2-tier-1"
  }
  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y curl apache2  # Include apache or nginx installation as per your setup
    AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
    echo "This instance is running in AZ: $AZ" > /var/www/html/index.html
  EOF
}


resource "aws_instance" "ec2_app1_tier_2" {
  ami                    = data.aws_ami.ami.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnet_app_tier[0].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  tags = {
    Name = "App1-tier-2"
  }
}

resource "aws_instance" "ec2_app2_tier_2" {
  ami                    = data.aws_ami.ami.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnet_app_tier[1].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  tags = {
    Name = "App2-tier-2"
  }
}


