output "myvpc_id" {
  value = aws_vpc.myvpc.id
  description = "VPC ID"
}

output "mysubnet_id" {
  value = aws_subnet.mysn.id
  description = "Subnet ID"
}

output "mysg_id" {
  value = aws_security_group.mysg.id
  description = "SG ID"
}