variable "dbuser" {
  type = string
  description = "DB user"
  sensitive = true
}

variable "dbpassword" {
  type = string
  description = "DB password"
  sensitive = true
}