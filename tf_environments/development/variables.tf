variable "region" {
  type        = string
  description = "The region to deploy the resources"
  default     = "us-east-1"
}
/**
  * VPC variables
  */
variable "public_subnets" {
  type    = list(string)
  default = []
}

variable "private_subnets" {
  type    = list(string)
  default = []
}

variable "availability_zones" {
  type    = list(string)
  default = []
}
/**
  * ECR variables
  */
variable "lambda_repo" {
  description = "The list of ecr lambda repos to create"
  type        = list(string)
  default     = null
}
variable "service_repo" {
  description = "The list of ecr service repos to create"
  type        = list(string)
  default     = null
}
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
variable "image_mutability" {
  description = "Provide image mutability"
  type        = string
  default     = "MUTABLE"
}

variable "encrypt_type" {
  description = "Provide type of encryption here"
  type        = string
  default     = "KMS"
}

/**
  * S3 & Lambda variables
  */

variable "bucket_name" {
  type        = string
  description = "value of the bucket name"
  default     = ""
}

variable "s3_lambda_function_name" {
  type        = string
  description = "value of the lambda function name"
  default     = ""
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "eks_cluster_name" {
  type    = string
  default = ""
}

