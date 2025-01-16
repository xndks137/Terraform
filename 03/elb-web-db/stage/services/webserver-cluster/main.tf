provider "aws" {
  region = "us-east-2"
}

# 작업 절차
# 1. 기본 인프라 구성
# VPC    : 기본 VPC
# Subnet : 기본 SN

# 2. ALB + TG(ASG, EC2 x 2)
# 2-1. ASG
#   - 보안 그룹 생성(시작 템플릿용)
#   - 시작 템플릿
#   - ASG
# 2-2. ALB + TG
#   - 보안 그룹 생성(대상 그룹용)
#   - TG
#   - ALB
#     - LB
#     - Listener
#     - Listener Rule
#     - Target Group

# 1. 기본 인프라 구성
# VPC    : 기본 VPC
data "aws_vpc" "default" {
  default = true
}
# Subnet : 기본 SN
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 2. ALB + TG(ASG, EC2 x 2)
# 2-1. ASG
#   - 보안 그룹 생성(시작 템플릿용) * ingress: 8080/tcp, egress: all traffic
resource "aws_security_group" "asg-sg" {
  name        = "myasg-sg"
  description = "Allow 8080/tcp inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "myasg-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_SSH" {
  security_group_id = aws_security_group.asg-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_8080" {
  security_group_id = aws_security_group.asg-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.asg-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#   - 시작 템플릿
resource "aws_launch_template" "asg_template" {
  name                   = "myLT"
  image_id               = data.aws_ami.ubuntu2404.id
  instance_type          = "t2.micro"
  key_name               = "mykeypair2"
  vpc_security_group_ids = [aws_security_group.asg-sg.id]

  user_data = base64encode(templatefile("user-data.sh", {
    db_address  = data.terraform_remote_state.myTFstate.outputs.address,
    db_port     = data.terraform_remote_state.myTFstate.outputs.port,
    server_port = 8080
  }))

  # provisioner "local-exec" {
  #   command = templatefile("user-data.sh", {
  #     db_address = data.terraform_remote_state.myTFstate.outputs.address,
  #     db_port = data.terraform_remote_state.myTFstate.outputs.port,
  #     server_port = 8080})
  # }
  # user_data = filebase64("./user-data.sh")

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "myLT"
    }
  }
}

#   - ASG
# *(warning) target_group_arn
resource "aws_autoscaling_group" "ASG" {
  name                      = "myASG"
  max_size                  = 10
  min_size                  = 2
  desired_capacity          = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"

  vpc_zone_identifier = data.aws_subnets.default.ids

  launch_template {
    id      = aws_launch_template.asg_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.alb-tg.arn]

  tag {
    key                 = "Name"
    value               = "myASG"
    propagate_at_launch = true
  }
}

# 2-2. ALB + TG
#   - 보안 그룹 생성(대상 그룹용)
resource "aws_security_group" "alb-sg" {
  name        = "myalb-sg"
  description = "Allow HTTP inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "myalb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "lb_80" {
  security_group_id = aws_security_group.alb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "lb_all_traffic" {
  security_group_id = aws_security_group.alb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#   - TG
resource "aws_lb_target_group" "alb-tg" {
  name     = "myalb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
}

#   - ALB
#     - LB
resource "aws_lb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = data.aws_subnets.default.ids

}

#     - Listener
resource "aws_lb_listener" "myalb_listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg.arn
  }
}

#### Data Sources ####
# AMI_id
data "aws_ami" "ubuntu2404" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# tfstate
data "terraform_remote_state" "myTFstate" {
  backend = "s3"
  config = {
    bucket = "mybucket-kyh-0128"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-2"
  }
}
