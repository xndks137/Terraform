output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "alb_dns_name" {
  value = module.networking.alb_dns_name
}
