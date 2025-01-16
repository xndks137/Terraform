provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "terraform-state" {
  bucket = "mybucket-kyh-0128"

  # https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle
  force_destroy = true

  # 코드 이력을 관리하기 위해 상태 파일의 버전 관리를 활성화 한다.
  # versioning {
  #   enabled = true
  # }

  # 서버 측 암호화를 활성화 한다.
  # server_side_encryption_configuration {
  #   rule {
  #     apply_server_side_encryption_by_default {
  #       sse_algorithm = "AES256"
  #     }
  #   }
  # }

  tags = {
    Name = "My bucket"
  }
}

# Resource: aws_s3_bucket_public_access_block
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "terraform_state_acl" {
  bucket = aws_s3_bucket.terraform-state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table
resource "aws_dynamodb_table" "terraform-locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S" # 값은 S(string), N(number), B(binary) 중 하나이어야 한다.
  }
}

