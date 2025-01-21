variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of public subnets"
  type        = list(string)
}

variable "lb_name" {
  description = "Name of the load balancer"
  type        = string
}

variable "target_group_name" {
  description = "Name of the target group"
  type        = string
}
