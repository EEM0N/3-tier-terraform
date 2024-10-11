#Create security group for application load balancer
resource "aws_security_group" "app_sg" {
  name        = "Project-ALB-SG"
  description = "Allows web access"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name = "Project-ALB-SG"
  }
}

# Security group for EC2 instances
resource "aws_security_group" "ec2_sg" {
  name        = "Project-EC2-SG"
  description = "Allows ALB to access the EC2 instances"
  vpc_id      = aws_vpc.app_vpc.id

  # Allow HTTP traffic from ALB
  ingress {
    description     = "Allow port 80 traffic from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = [aws_vpc.app_vpc.cidr_block]  
  }

  # Allow HTTPS traffic from ALB
  ingress {
    description     = "Allow port 443 traffic from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = [aws_vpc.app_vpc.cidr_block]  
  }

  # Allow traffic to RDS on port 3306
  egress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = [aws_vpc.app_vpc.cidr_block]  # Use VPC CIDR block
  }

  # Allow outbound traffic to the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  tags = {
    Name = "Project-EC2-SG"
  }
}

#Create security group for RDS database instances
resource "aws_security_group" "rds_sg" {
  name        = "Project-RDS-SG"
  description = "Allows application to access the RDS instances"
  vpc_id      = aws_vpc.app_vpc.id

  # Allow MySQL traffic from EC2 instances
  ingress {
    description     = "Allow port 3306 traffic from EC2 instances"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = [aws_vpc.app_vpc.cidr_block]  
  }

  # Allow all outbound traffic from RDS (default behavior)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Project-RDS-SG"
  }
}

