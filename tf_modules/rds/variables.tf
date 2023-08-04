
variable "vpc_id" {
  description = "The ID of the VPC in which to create the security group"
  type        = string
}

variable "cluster_identifier" {
  description = "The name of the cluster"
  type        = string
}

variable "engine" {
  description = "The database engine to use"
  type        = string
}

variable "storage_type" {
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD)"
  type        = string
}

variable "allocated_storage" {
  description = "The allocated storage in gibibytes"
  type        = number
}

variable "iops" {
  description = "The amount of provisioned IOPS. Setting this implies a storage_type of 'io1'"
  type        = number
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
}

variable "database_name" {
  description = "The name of the database to create when the DB instance is created"
  type        = string
  default     = "test"
}

variable "master_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "test"
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "availability_zones" {
  description = "A list of EC2 availability zones for the DB subnet group"
  type        = list(string)
}

variable "subnet_group_name" {
  description = "The name of the DB subnet group"
  type        = string
  default     = "rds-subnet-group"
}

variable "security_group_name" {
  description = "The name of the security group"
  type        = string
  default     = "rds-security-group"
}
