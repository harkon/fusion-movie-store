variable "rds_secret_arn" {
  type        = string
  description = "ARN of the secret storing the master password in AWS Secrets Manager"
}

variable "db_host" {
  type        = string
  description = "The endpoint of the RDS instance"
}

variable "db_name" {
  type        = string
  description = "The name of the database"
}

variable "service_repo" {
  type        = list(string)
  description = "The URI of the Docker image"
}

variable "repository_urls" {
  type        = map(string)
  description = "The URI of the Docker image"
}

variable "redis_host" {
  type        = string
  description = "The endpoint of the Redis instance"
}

variable "redis_port" {
  type        = number
  description = "The port of the Redis instance"
}

variable "redis_password" {
  type = string
  description = "The password for the Redis instance"
  sensitive = true
}

variable "availability_zones" {
  type        = list(string)
  description = "The availability zones to deploy the resources"
}
