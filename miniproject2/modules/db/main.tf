# Security group 생성
resource "aws_security_group" "allow_db" {
  name        = "allow_db"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.selected.id

  tags = {
    Name = "allow_db"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_db" {
  security_group_id = aws_security_group.allow_db.id
  cidr_ipv4         = data.aws_vpc.selected.cidr_block
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}

resource "aws_vpc_security_group_egress_rule" "allow_db" {
  security_group_id = aws_security_group.allow_db.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# DB subnet group 생성
resource "aws_db_subnet_group" "subnet_group" {
  name       = "${lower(var.name)}-subnet-group"
  subnet_ids = data.aws_subnets.subnets.ids
  # subnet_ids = var.subnets

  tags = {
    Name = "${var.name}-subnet-group"
  }
}

# DB instance 생성
resource "aws_db_instance" "mysql" {
  identifier           = "${var.name}-db"
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  skip_final_snapshot = true
  parameter_group_name = "default.mysql8.0"

  db_name  = var.name
  username = var.db_username
  password = var.db_password

  vpc_security_group_ids = [aws_security_group.allow_db.id]
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name
}


data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}