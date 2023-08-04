output "primary_endpoint" {
  value = aws_elasticache_replication_group.cache_cluster.primary_endpoint_address
}

output "reader_endpoint" {
  value = aws_elasticache_replication_group.cache_cluster.reader_endpoint_address
}

output "configuration_endpoint" {
  value = aws_elasticache_replication_group.cache_cluster.configuration_endpoint_address
}

output "port" {
  value = aws_elasticache_replication_group.cache_cluster.port
}

output "password" {
  sensitive = true
  value     = aws_secretsmanager_secret_version.cache_password.secret_string
}

# output "redis_shard_endpoints" {
#   description = "List of Redis Shard Endpoints"
#   value = [for cluster in data.aws_elasticache_cluster.clusters : "${cluster.cache_nodes[0].address}:${cluster.cache_nodes[0].port}"]
# }

output "redis_shard_endpoints" {
  value = jsonencode([
    for cluster in data.aws_elasticache_cluster.clusters :
    {
      host = cluster.cache_nodes[0].address,
      port = cluster.cache_nodes[0].port
    }
  ])
}


