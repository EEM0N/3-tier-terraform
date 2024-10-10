# Create a VPC for the application
resource "aws_vpc" "app_vpc" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = var.vpc_name
  }
}
##############################################################
# gateway
##############################################################
# Create an Internet Gateway for the VPC
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "app-internet-gateway"
  }
}

# Allocate an Elastic IP for the NAT Gateway
resource "aws_eip" "nat_eip_1" {
  domain = "vpc"
}

# Allocate an Elastic IP for the NAT Gateway
resource "aws_eip" "nat_eip_2" {
  domain = "vpc"
}

# Create a NAT Gateway in the first public subnet
resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.nat_eip_1.id
  subnet_id     = aws_subnet.public_subnet_web_tier[0].id

  tags = {
    Name = "app-nat-gateway-1"
  }

  # Ensure proper ordering by depending on the Internet Gateway
  depends_on = [aws_internet_gateway.internet_gateway]
}

# Create a NAT Gateway in the first public subnet
resource "aws_nat_gateway" "nat_gateway_2" {
  allocation_id = aws_eip.nat_eip_2.id
  subnet_id     = aws_subnet.public_subnet_web_tier[1].id

  tags = {
    Name = "app-nat-gateway-2"
  }

  # Ensure proper ordering by depending on the Internet Gateway
  depends_on = [aws_internet_gateway.internet_gateway]
}
##############################################################
# web tier
##############################################################
resource "aws_subnet" "public_subnet_web_tier" {
  count                   = length(var.web_tier_cidr_block)
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.web_tier_cidr_block[count.index]
  availability_zone       = data.aws_availability_zones.azs.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "web-tier-public-subnet-${element(data.aws_availability_zones.azs.names, count.index)}"
  }
}

# Create a route table for public subnets
resource "aws_route_table" "public_route_table_zoneA" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "public-route-table-zoneA"
  }
}

# Create a route table for public subnets
resource "aws_route_table" "public_route_table_zoneB" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "public-route-table-zoneB"
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_subnet_association_zoneA" {
  subnet_id      = aws_subnet.public_subnet_web_tier[0].id
  route_table_id = aws_route_table.public_route_table_zoneA.id
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_subnet_association_zoneB" {
  subnet_id      = aws_subnet.public_subnet_web_tier[1].id
  route_table_id = aws_route_table.public_route_table_zoneB.id
}

# Create a route for the public route table to allow outbound traffic
resource "aws_route" "public_route_zoneA" {
  route_table_id         = aws_route_table.public_route_table_zoneA.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

# Create a route for the public route table to allow outbound traffic
resource "aws_route" "public_route_zoneB" {
  route_table_id         = aws_route_table.public_route_table_zoneB.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}
##############################################################
# app tier
##############################################################
resource "aws_subnet" "private_subnet_app_tier" {
  count             = length(var.app_tier_cidr_block)
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.app_tier_cidr_block[count.index]
  availability_zone = data.aws_availability_zones.azs.names[count.index]

  tags = {
    Name = "app-tier-private-subnet-${element(data.aws_availability_zones.azs.names, count.index)}"
  }
}

# Create a route table for public subnets
resource "aws_route_table" "private_route_table_zoneA" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "private-route-table-zoneA"
  }
}

# Create a route table for public subnets
resource "aws_route_table" "private_route_table_zoneB" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "private-route-table-zoneB"
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "private_subnet_association_zoneA" {
  subnet_id      = aws_subnet.private_subnet_app_tier[0].id
  route_table_id = aws_route_table.private_route_table_zoneA.id
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "private_subnet_association_zoneB" {
  subnet_id      = aws_subnet.private_subnet_app_tier[1].id
  route_table_id = aws_route_table.private_route_table_zoneB.id
}

# Create a route for private subnets to allow outbound traffic through the NAT Gateway
resource "aws_route" "private_route_zoneA" {
  route_table_id         = aws_route_table.private_route_table_zoneA.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat_gateway_1.id
}

# Create a route for private subnets to allow outbound traffic through the NAT Gateway
resource "aws_route" "private_route_zoneB" {
  route_table_id         = aws_route_table.private_route_table_zoneB.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat_gateway_2.id
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
resource "aws_route_table" "db_route_table_zoneA" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "db-route-table-zoneA"
  }
}

# Create a route table for public subnets
resource "aws_route_table" "db_route_table_zoneB" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "db-route-table-zoneB"
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "db_private_subnet_association_zoneA" {
  subnet_id      = aws_subnet.private_subnet_db_tier[0].id
  route_table_id = aws_route_table.db_route_table_zoneA.id
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "db_private_subnet_association_zoneB" {
  subnet_id      = aws_subnet.private_subnet_db_tier[1].id
  route_table_id = aws_route_table.db_route_table_zoneB.id
}

# Create a route for private subnets to allow outbound traffic through the NAT Gateway
resource "aws_route" "db_private_route_zoneA" {
  route_table_id         = aws_route_table.db_route_table_zoneA.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat_gateway_1.id
}

# Create a route for private subnets to allow outbound traffic through the NAT Gateway
resource "aws_route" "db_private_route_zoneB" {
  route_table_id         = aws_route_table.db_route_table_zoneB.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat_gateway_2.id
}