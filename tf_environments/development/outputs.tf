output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}

output "lambda_functions" {
  value = module.lambda.lambda_functions
}

output "host" {
  value = module.rds_cluster.host
}

output "user" {
  value = module.rds_cluster.username
}

output "arn" {
  value = module.rds_cluster.secret_arn
}
output "db_host" {
  value = module.rds_cluster.host
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}



output "reader_endpoint_address" {
  value = module.elasticache.reader_endpoint
}

output "primary_endpoint_address" {
  value = module.elasticache.primary_endpoint
}

output "redis_port" {
  value = module.elasticache.port
}

output "api_gateway_url" {
  value = module.api.api_gateway_url
}

output "load_balancer_dns_names" {
  value = module.k8s.load_balancer_ingress_hostname
}


output "redis_shard_endpoints" {
  value = module.elasticache.redis_shard_endpoints
}