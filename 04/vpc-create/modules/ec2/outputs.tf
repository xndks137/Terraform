output "public_ip" {
  value = aws_instance.myEC2.public_ip
  description = "Instance Public IP"
}