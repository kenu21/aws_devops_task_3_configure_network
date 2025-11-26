output "subnet_id" {
  description = "ID of the VPC subnet, deployed by the module"
  value       = aws_subnet.grafana_subnet.id
}

output "security_group_id" {
  description = "ID of the security group, deployed by the module"
  value       = aws_security_group.grafana_sg.id
}
