variable "region" {
  description = "The AWS region"
  type        = string
}

variable "account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "secret_arn" {
  description = "The ARN of the secret"
  type        = string
}

variable "kms_key_id" {
  description = "The ID of the KMS key"
  type        = string
}

variable "lambda_repo" {
  description = "The name of the ECR registry repositories for lambda functions"
  type        = list(string)
  default     = null
}

variable "repository_urls" {
  type        = map(string)
  description = "The set of lambda images"
}


variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnets_ids" {
  description = "The subnet IDs of the Lambda function"
  type        = list(string)
  default     = []
}

variable "environment_variables" {
  description = "A map of environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

