resource "aws_launch_template" "web_was" {
  name_prefix   = "web-was-"
  instance_type = var.instance_type
  image_id      = var.ami_id
  
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.web_was.id]
  }

  user_data = base64encode(var.user_data)
}

resource "aws_autoscaling_group" "web_was" {
  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  min_size         = var.min_size
  
  vpc_zone_identifier = var.public_subnet_ids
  
  launch_template {
    id      = aws_launch_template.web_was.id
    version = "$Latest"
  }
  
  target_group_arns = [var.target_group_arn]
}

resource "aws_security_group" "web_was" {
  name        = "web-was-sg"
  description = "Security group for Web/WAS tier"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.elb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
