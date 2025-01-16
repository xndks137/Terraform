terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.83.1"
    }
  }
  backend "s3" {
    bucket         = "mybucket-kyh-0128"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_db_instance" "myDBInstance" {
  allocated_storage = 10

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"

  db_name  = "mydb"
  username = var.dbuser     # 변수로 사용
  password = var.dbpassword # 변수로 사용

  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}
