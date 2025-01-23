output "all_users" {
  value = aws_iam_user.createuser
  description = "The ARNs for all users"
}