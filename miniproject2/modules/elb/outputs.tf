output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.web.dns_name
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.web.arn
}

output "security_group_id" {
  description = "The ID of the ELB security group"
  value       = aws_security_group.elb.id
}
