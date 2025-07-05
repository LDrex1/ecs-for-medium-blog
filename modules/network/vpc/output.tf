output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_id" {
  description = "The single public subnet ID"
  value       = aws_subnet.amh_public[*].id
}

output "private_subnet_ids" {
  description = "The single public subnet ID"
  value = [for sub in aws_subnet.amh_private :
    sub.id
    if !sub.map_public_ip_on_launch
  ]
}
