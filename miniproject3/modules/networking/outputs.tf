output "vpc_id" {
  value = aws_default_vpc.default.id
}

output "subnet_ids" {
  value = data.aws_subnets.default.ids
}

output "security_group_id" {
  value = aws_security_group.ecs_tasks.id
}

output "target_group_arn" {
  value = aws_lb_target_group.main.arn
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
} 