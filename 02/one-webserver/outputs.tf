output "public_ip" {
  value = aws_instance.test.public_ip
  description = "The public IP of the Instance"
}