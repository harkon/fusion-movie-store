variable "account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "private_subnets_ids" {
  description = "The subnets for the EKS cluster"
  type        = list(string)
}

variable "node_desired_size" {
  description = "The desired number of worker nodes"
  type        = number
  default     = 3
}

variable "node_max_size" {
  description = "The maximum number of worker nodes"
  type        = number
  default     = 6
}

variable "node_min_size" {
  description = "The minimum number of worker nodes"
  type        = number
  default     = 3
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "rds_port" {
  description = "The port for the RDS instance"
  type        = number
  default     = 3306
}

variable "redis_port" {
  description = "The port for the Redis instance"
  type        = number
  default     = 6379
}
