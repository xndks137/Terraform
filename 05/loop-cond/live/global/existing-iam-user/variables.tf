variable "user_names" {
  description = "Create IAM users"
  type = list(string)
  default = [ "red","blue","green" ]
}