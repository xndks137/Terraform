variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "github_repo_name" {
  description = "GitHub repository name (format: owner/repo)"
  type        = string
}

variable "github_branch_name" {
  description = "GitHub branch name"
  type        = string
  default     = "main"
}

variable "buildspec_path" {
  description = "Path to the buildspec file"
  type        = string
  default     = "buildspec.yml"
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-2"
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "container_name" {
  description = "Name of the container in ECS task definition"
  type        = string
}