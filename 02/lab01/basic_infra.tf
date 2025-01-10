# Provider 설정
provider "aws" {
  region = "us-east-2"
}

# VPC 생성
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "myVPC"
  }
}

# Internet GW 생성
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "myIGW"
  }
}

# Public SN 생성
resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "mySubnet"
  }
}

# RT 생성 & Public SN 연결
resource "aws_route_table" "myPubRT" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "myPubRT"
  }
}

resource "aws_route_table_association" "main-myPubRT" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.myPubRT.id
}

# 보안그룹 생성
resource "aws_security_group" "mySG-SSH-HTTP" {
  name        = "mySG-SSH-HTTP"
  description = "Allow SSH, HTTP inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "mySG-SSH-HTTP"
  }
}

# 보안규칙 생성(인바운드)
resource "aws_vpc_security_group_ingress_rule" "allow_HTTP" {
  security_group_id = aws_security_group.mySG-SSH-HTTP.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_SSH" {
  security_group_id = aws_security_group.mySG-SSH-HTTP.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# 보안규칙 생성(아웃바운드)
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.mySG-SSH-HTTP.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# EC2 생성
resource "aws_instance" "myEC2" {
  ami                    = "ami-0d7ae6a161c5c4239"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.mySG-SSH-HTTP.id]
  subnet_id              = aws_subnet.main.id
  user_data              = <<-EOF
    #!/bin/bash
    yum -y install httpd
    echo 'MyWEB' > /var/www/html/index.html
    systemctl enable --now httpd
    EOF

  user_data_replace_on_change = true

  tags = {
    Name = "myEC2"
  }
}