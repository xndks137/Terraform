output "db_instance_endpoint" {
  description = "The connection endpoint for the database"
  value       = aws_db_instance.default.endpoint
}

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.default.id
}

output "security_group_id" {
  description = "The ID of the database security group"
  value       = aws_security_group.db.id
}
