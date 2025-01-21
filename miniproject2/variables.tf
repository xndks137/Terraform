variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}
