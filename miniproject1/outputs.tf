# Output Block
output "EC2_public_ip" {
  value = aws_instance.devEC2.public_ip
  description = "EC2 Public IP"
}