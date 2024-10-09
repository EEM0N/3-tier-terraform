# Create a VPC for the application
resource "aws_vpc" "app_vpc" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = var.vpc_name
  }
}
##############################################################
# web tier
resource "aws_subnet" "public_subnet_web_tier" {
  count                   = length(var.web_tier_cidr_block)
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.web_tier_cidr_block[count.index]
  availability_zone       = data.aws_availability_zones.azs.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "web tier public-subnet-${element(data.aws_availability_zones.azs.names, count.index)}"
  }
}

# Create a route table for public subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "public-route-table"
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.web_tier_cidr_block)
  subnet_id      = aws_subnet.public_subnet_web_tier[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Create an Internet Gateway for the VPC
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "app-internet-gateway"
  }
}

# Create a route for the public route table to allow outbound traffic
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}
##############################################################
# app tier
resource "aws_subnet" "private_subnet_app_tier" {
  count             = length(var.app_tier_cidr_block)
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.app_tier_cidr_block[count.index]
  availability_zone = data.aws_availability_zones.azs.names[count.index]

  tags = {
    Name = "app tier public-subnet-${element(data.aws_availability_zones.azs.names, count.index)}"
  }
}

# Create a route table for public subnets
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "private-route-table"
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "private_subnet_association" {
  count          = length(var.app_tier_cidr_block)
  subnet_id      = aws_subnet.private_subnet_app_tier[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}


# Allocate an Elastic IP for the NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# Create a NAT Gateway in the first public subnet
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_web_tier[0].id

  tags = {
    Name = "app-nat-gateway"
  }

  # Ensure proper ordering by depending on the Internet Gateway
  depends_on = [aws_internet_gateway.internet_gateway]
}

# Create a route for private subnets to allow outbound traffic through the NAT Gateway
resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat_gateway.id
}
##############################################################
# db tier
resource "aws_subnet" "private_subnet_db_tier" {
  count             = length(var.db_tier_cidr_block)
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.db_tier_cidr_block[count.index]
  availability_zone = data.aws_availability_zones.azs.names[count.index]

  tags = {
    Name = "db tier public-subnet-${element(data.aws_availability_zones.azs.names, count.index)}"
  }
}

# Create a route table for public subnets
resource "aws_route_table" "db_route_table" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "db-route-table"
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "db_private_subnet_association" {
  count          = length(var.db_tier_cidr_block)
  subnet_id      = aws_subnet.private_subnet_db_tier[count.index].id
  route_table_id = aws_route_table.db_route_table.id
}

# Create a route for private subnets to allow outbound traffic through the NAT Gateway
resource "aws_route" "db_private_route" {
  route_table_id         = aws_route_table.db_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat_gateway.id
}

# Create a DB subnet group for RDS
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = aws_subnet.private_subnet_db_tier[*].id

  tags = {
    Name = "Database Subnet Group"
  }
}