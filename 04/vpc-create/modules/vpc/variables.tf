variable "vpc_cidr" {
  default = "10.0.0.0/16"
  description = "VPC CIDR"
  type = string
}

variable "name" {
  default = "my"
  type = string
  description = "Tags"
}

variable "vpc_subnet" {
  default = "10.0.1.0/24"
  type = string
  description = "Subnet CIDR"
}


