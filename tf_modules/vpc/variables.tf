variable "region" {
  type        = string
  description = "The region to deploy the resources"
}

variable "name" {
  type        = string
  description = "Name of the VPC"
}

variable "cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public Subnet CIDR values"
}

variable "private_subnets" {
  type        = list(string)
  description = "Private Subnet CIDR values"
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability Zones"
}

variable "eks_cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

# variable "private_subnet_ids" {
#   type = list(string)
# }
