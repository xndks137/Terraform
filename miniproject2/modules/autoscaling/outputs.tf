output "asg_name" {
  description = "The name of the Auto Scaling Group"
  value       = aws_autoscaling_group.web_was.name
}

output "security_group_id" {
  description = "The ID of the Web/WAS security group"
  value       = aws_security_group.web_was.id
}
