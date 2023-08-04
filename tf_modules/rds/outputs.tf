output "host" {
  description = "Endpoint for the RDS cluster"
  value       = aws_rds_cluster.cluster.endpoint
}

output "database" {
  description = "Name of the database in the RDS cluster"
  value       = aws_rds_cluster.cluster.database_name
}

output "username" {
  description = "Username for the RDS cluster"
  value       = aws_rds_cluster.cluster.master_username
}

output "secret_arn" {
  description = "ARN of the secret storing the master password in AWS Secrets Manager"
  value       = aws_rds_cluster.cluster.master_user_secret[0].secret_arn
}

output "kms_key_id" {
  description = "KMS key ID used to encrypt the master password in AWS Secrets Manager"
  value       = aws_kms_key.key_rds.key_id
}

locals {
  db_credentials = jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string)
}

output "master_password" {
  description = "The master password for the RDS cluster"
  value       = local.db_credentials["password"]
  sensitive   = true
}