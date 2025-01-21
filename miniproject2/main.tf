module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = "10.0.0.0/16"
  vpc_name             = "main-vpc"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  availability_zones   = ["ap-northeast-2b", "ap-northeast-2d"]
}

module "elb" {
  source             = "./modules/elb"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  lb_name            = "web-lb"
  target_group_name  = "web-tg"
}

module "web_was" {
  source                 = "./modules/autoscaling"
  vpc_id                 = module.vpc.vpc_id
  public_subnet_ids      = module.vpc.public_subnet_ids
  instance_type          = "t3.micro"
  ami_id                 = "ami-0a998385ed9f45655"
  desired_capacity       = 2
  max_size               = 2
  min_size               = 2
  target_group_arn       = module.elb.target_group_arn
  elb_security_group_id  = module.elb.security_group_id
  user_data              = file("userdata.tpl")
}

module "db" {
  source                    = "./modules/rds"
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  db_subnet_group_name      = "main"
  allocated_storage         = 10
  engine                    = "mysql"
  engine_version            = "5.7"
  instance_class            = "db.t3.micro"
  db_name                   = "mydb"
  db_username               = var.db_username
  db_password               = var.db_password
  parameter_group_name      = "default.mysql5.7"
  web_was_security_group_id = module.web_was.security_group_id
}
