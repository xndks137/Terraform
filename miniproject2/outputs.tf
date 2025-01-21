output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.elb.lb_dns_name
}

output "web_was_asg_name" {
  description = "The name of the Web/WAS Auto Scaling Group"
  value       = module.web_was.asg_name
}

output "db_instance_endpoint" {
  description = "The connection endpoint for the database"
  value       = module.db.db_instance_endpoint
}
