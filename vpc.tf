resource "aws_vpc" "IBM_VPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = "MAIN-IBM-VPC"
  }
}

# PUBLIC SUBNET
resource "aws_subnet" "ibm_web_subnet" {
  vpc_id     = aws_vpc.IBM_VPC.id
  cidr_block = "10.0.0.0/20"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "IBM-WEB-SUBNET"
  }
}

# PRIVATE SUBNET
resource "aws_subnet" "ibm_data_subnet" {
  vpc_id     = aws_vpc.IBM_VPC.id
  cidr_block = "10.0.16.0/20"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "IBM-DATABASE-SUBNET"
  }
}
# INTERNET GATEWAY
resource "aws_internet_gateway" "ibm-gateway" {
  vpc_id = aws_vpc.IBM_VPC.id

  tags = {
    Name = "ibm-internet-gateway"
  }
}

#ROUTE TABLES
#PUBLIC ROUTE TABLE
resource "aws_route_table" "IBM_WEB_ROUTE_TABLE" {
  vpc_id = aws_vpc.IBM_VPC.id


  tags = {
    Name = "IBM_ROUTE_TABLE-WEB"
  }
}

#Public route table asociation
resource "aws_route_table_association" "web-association" {
  subnet_id      = aws_subnet.ibm_web_subnet.id
  route_table_id = aws_route_table.IBM_WEB_ROUTE_TABLE.id
}


#Private  ROUTE TABLE
resource "aws_route_table" "IBM_DATABASE_ROUTE_TABLE" {
  vpc_id = aws_vpc.IBM_VPC.id


  tags = {
    Name = "IBM_ROUTE_TABLE-DATABASE"
  }
}

#Private route table asociation
resource "aws_route_table_association" "database-association" {
  subnet_id      = aws_subnet.ibm_data_subnet.id
  route_table_id = aws_route_table.IBM_DATABASE_ROUTE_TABLE.id
}

#  NACL for WEB (public)

resource "aws_network_acl" "WEB_NACL" {
  vpc_id = aws_vpc.IBM_VPC.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "IBM-WEB-NACL"
  }
}


#PUBLIC NETWORK ACL ASSOICATION
resource "aws_network_acl_association" "nacl-web-association" {
  network_acl_id = aws_network_acl.WEB_NACL.id
  subnet_id      = aws_subnet.ibm_web_subnet.id
}



#  NACL for DATABASE (PRIVATE)

resource "aws_network_acl" "DATABASE_NACL" {
  vpc_id = aws_vpc.IBM_VPC.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "IBM-DATABASE-NACL"
  }
}


#PRIVATE NETWORK ACL ASSOICATION
resource "aws_network_acl_association" "nacl-database-association" {
  network_acl_id = aws_network_acl.DATABASE_NACL.id
  subnet_id      = aws_subnet.ibm_data_subnet.id
}


#Security GROUP FOR WEB

resource "aws_security_group" "ibm-web-sg" {
  name        = "ibm-web-server-sg"
  description = "Allow web server traffic "
  vpc_id      = aws_vpc.IBM_VPC.id

  tags = {
    Name = "web-secruity-group"
  }
}

#SSH TRAFFIC
resource "aws_vpc_security_group_ingress_rule" "ibm-web-ssh" {
  security_group_id = aws_security_group.ibm-web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

#HTTP traffic
resource "aws_vpc_security_group_ingress_rule" "ibm-http-ssh" {
  security_group_id = aws_security_group.ibm-web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "IBM-outbound" {
  security_group_id = aws_security_group.ibm-web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "tcp"
  to_port           = 65535
}