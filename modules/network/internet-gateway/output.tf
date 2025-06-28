output "ig_name" {
  description = "name of internet gateway"
  value       = var.ig_name
}

output "ig_id" {
  description = "name of internet gateway"
  value       = aws_internet_gateway.ig_gateway.id
}