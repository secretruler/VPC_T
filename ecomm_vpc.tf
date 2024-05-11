# Define VPC
resource "aws_vpc" "ecomm_VPC" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "MAIN-ecomm-VPC"
  }
}

# Define Public Subnet
resource "aws_subnet" "ecomm_web_subnet" {
  vpc_id            = aws_vpc.ecomm_VPC.id
  cidr_block        = "10.10.0.0/20"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "ecomm-WEB-SUBNET"
  }
}

# Define Private Subnet
resource "aws_subnet" "ecomm_data_subnet" {
  vpc_id            = aws_vpc.ecomm_VPC.id
  cidr_block        = "10.10.16.0/20"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "ecomm-DATABASE-SUBNET"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "ecomm-gateway" {
  vpc_id = aws_vpc.ecomm_VPC.id

  tags = {
    Name = "ecomm-internet-gateway"
  }
}

# Define Public Route Table
resource "aws_route_table" "ecomm_WEB_ROUTE_TABLE" {
  vpc_id = aws_vpc.ecomm_VPC.id

  tags = {
    Name = "ecomm_ROUTE_TABLE-WEB"
  }
}

# Associate Public Route Table with Public Subnet
resource "aws_route_table_association" "web-association" {
  subnet_id      = aws_subnet.ecomm_web_subnet.id
  route_table_id = aws_route_table.ecomm_WEB_ROUTE_TABLE.id
}

# Define Private Route Table
resource "aws_route_table" "ecomm_DATABASE_ROUTE_TABLE" {
  vpc_id = aws_vpc.ecomm_VPC.id

  tags = {
    Name = "ecomm_ROUTE_TABLE-DATABASE"
  }
}

# Associate Private Route Table with Private Subnet
resource "aws_route_table_association" "database-association" {
  subnet_id      = aws_subnet.ecomm_data_subnet.id
  route_table_id = aws_route_table.ecomm_DATABASE_ROUTE_TABLE.id
}

# Define Public Network ACL
resource "aws_network_acl" "WEB_NACL" {
  vpc_id = aws_vpc.ecomm_VPC.id

  tags = {
    Name = "ecomm-WEB-NACL"
  }
}

# Associate Public Network ACL with Public Subnet
resource "aws_network_acl_association" "ecomm-web-association" {
  network_acl_id = aws_network_acl.WEB_NACL.id
  subnet_id      = aws_subnet.ecomm_web_subnet.id
}

# Define Private Network ACL
resource "aws_network_acl" "DATABASE_NACL" {
  vpc_id = aws_vpc.ecomm_VPC.id

  tags = {
    Name = "ecomm-DATABASE-NACL"
  }
}

# Associate Private Network ACL with Private Subnet
resource "aws_network_acl_association" "ecomm-database-association" {
  network_acl_id = aws_network_acl.DATABASE_NACL.id
  subnet_id      = aws_subnet.ecomm_data_subnet.id
}

# Define Security Group for Web Servers
resource "aws_security_group" "ecomm-web-sg" {
  name        = "ecomm-web-server-sg"
  description = "Allow web server traffic"
  vpc_id      = aws_vpc.ecomm_VPC.id

  tags = {
    Name = "web-security-group"
  }
}

# Ingress rule for SSH on Web Security Group
resource "aws_security_group_rule" "ecomm-web-ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecomm-web-sg.id
}

# Ingress rule for HTTP on Web Security Group
resource "aws_security_group_rule" "ecomm-web-http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecomm-web-sg.id
}

# Egress rule for all traffic on Web Security Group
resource "aws_security_group_rule" "ecomm-web-egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecomm-web-sg.id
}
