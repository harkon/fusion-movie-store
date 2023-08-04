variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "private_subnets_ids" {
  type        = list(string)
  description = "List of IDs for the private subnets"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "List of allowed CIDR blocks for the cache security group"
  default     = ["10.0.0.0/16"]
}

variable "node_type" {
  type        = string
  description = "Elasticache node type"
  default     = "cache.t2.micro"
}

variable "num_cache_nodes" {
  type        = number
  description = "Number of cache nodes"
  default     = 1
}
