provider "aws" {
  region = "us-east-2"
}

resource "aws_db_instance" "myDBInstance" {
  allocated_storage    = 10

  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t2.micro"

  db_name              = "mydb"
  username             = "foo"       # 변수로 사용
  password             = "foobarbaz" # 변수로 사용

  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}