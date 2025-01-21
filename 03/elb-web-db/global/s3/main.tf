resource "aws_s3_bucket" "terraform-state" {
  bucket = "mybucket-kyh-0128"
  force_destroy = true

  tags = {
    Name = "My bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state_acl" {
  bucket = aws_s3_bucket.terraform-state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform-locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

