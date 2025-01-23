module "ecr" {
  source = "./modules/ecr"
  name   = var.app_name
}

module "iam" {
  source = "./modules/iam"
}

module "networking" {
  source = "./modules/networking"
  name   = var.app_name
}

module "ecs" {
  source = "./modules/ecs"

  app_name           = var.app_name
  ecr_repository_url = module.ecr.repository_url
  execution_role_arn = module.iam.ecs_task_execution_role_arn
  vpc_id             = module.networking.vpc_id
  subnet_ids         = module.networking.subnet_ids
  security_group_id  = module.networking.security_group_id
  target_group_arn   = module.networking.target_group_arn
}

data "aws_caller_identity" "current" {}

module "pipeline" {
  source = "./modules/pipeline"

  project_name       = var.project_name
  github_repo_name   = var.github_repo_name
  github_branch_name = var.github_branch_name
  buildspec_path     = "buildspec.yml"

  aws_region          = var.aws_region
  account_id          = data.aws_caller_identity.current.account_id
  ecr_repository_name = module.ecr.repository_name
  container_name      = var.app_name

  ecs_cluster_name = module.ecs.cluster_name
  ecs_service_name = module.ecs.service_name
}
