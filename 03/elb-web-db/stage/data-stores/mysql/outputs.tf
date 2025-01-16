output "address" {
  value       = aws_db_instance.myDBInstance.address
  description = "DB ip address"
}

output "port" {
  value       = aws_db_instance.myDBInstance.port
  description = "DB port"
}
