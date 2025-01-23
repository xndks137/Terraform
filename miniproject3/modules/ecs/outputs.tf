output "container_name" {
  value = aws_ecs_task_definition.app.container_definitions
}

output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "service_name" {
  value = aws_ecs_service.app.name
}