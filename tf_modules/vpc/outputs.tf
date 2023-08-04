output "vpc_id" {
  description = "value of the vpc id"
  value       = aws_vpc.default.id
}

output "public_subnets_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnets_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}
