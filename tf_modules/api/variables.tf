variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

# variable "load_balancer_ingress_hostname" {
#   type = string
# }

variable "region" {
  type = string
}
variable "load_balancer_arn" {
  type = string
}

variable "load_balancer_dns" {
  type = string
}