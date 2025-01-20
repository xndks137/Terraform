# VPC 생성
resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "${var.name}VPC"
  }
}

#IGW 생성 및 연결
resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "${var.name}IGW"
  }
}

# Public Subnet 생성
resource "aws_subnet" "mysn" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = var.vpc_subnet
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "${var.name}PublicSN"
  }
}

# Public Routing Table 생성
# Public Routing Table에 Default Router 설정
resource "aws_route_table" "myrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
  
  tags = {
    Name = "${var.name}PublicRT"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.mysn.id
  route_table_id = aws_route_table.myrt.id
}

resource "aws_security_group" "mysg" {
  name        = "allow_web"
  description = "Allow HTTP/HTTPS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myvpc.id
  tags = {
    Name = "${var.name}SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_HTTP" {
  security_group_id = aws_security_group.mysg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_HTTPS" {
  security_group_id = aws_security_group.mysg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.mysg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}