variable "service_repo" {
  description = "The name of the ECR registry repositories for service images"
  type        = any
  default     = null
}

variable "lambda_repo" {
  description = "The name of the ECR registry repositories for lambda functions"
  type        = any
  default     = null
}

variable "image_mutability" {
  description = "Provide image mutability"
  type        = string
  default     = "IMMUTABLE"
}


variable "encrypt_type" {
  description = "Provide type of encryption here"
  type        = string
  default     = "KMS"
}

variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}