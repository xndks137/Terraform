# provider 설정
provider "aws" {
  region = "us-east-2"
}

# SG 생성 - 8080
resource "aws_security_group" "allow_8080" {
  name        = var.security_group_name
  description = "Allow 8080 inbound traffic and all outbound traffic"
  tags = {
    "Name" = "my_allow_8080"
  }
}

# SG ingress rule
resource "aws_vpc_security_group_ingress_rule" "allow_8080_ipv4" {
  security_group_id = aws_security_group.allow_8080.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.server_port
  ip_protocol       = "tcp"
  to_port           = var.server_port
}

# SG egress rule
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_8080.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# EC2 생성
resource "aws_instance" "test" {
  ami           = "ami-036841078a4b68e14"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.allow_8080.id]

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello world" > index.html
    nohup busybox httpd -f -p 8080 &
    EOF

  user_data_replace_on_change = true

  tags = {
    Name = "HelloWorld"
  }
}