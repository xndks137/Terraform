variable "instance_type" {
  default = "t2.micro"
  description = "Instance Type"
  type = string
}

variable "ec2_tag" {
  default = {
    Name = "myEC2"
  }
  description = "EC2 Instance Tag"
  type = map(string)
}

variable "subnet_id" {
  description = "Subnet ID"
  type = string
}

variable "keypair" {
  description = "KeyPair"
  type = string
}

variable "sg_ids" {
  description = "Security Group IDs(list)"
  type = list
}