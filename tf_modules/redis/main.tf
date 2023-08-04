
resource "aws_elasticache_subnet_group" "cache_cluster" {
  name       = "cache-subnet-group"
  subnet_ids = var.private_subnets_ids
}

/******************************************************
  Redis Security Group
******************************************************/
resource "aws_security_group" "cache_cluster" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }
}

resource "aws_cloudwatch_log_group" "cache_cluster" {
  name              = "/aws/redis/cache-cluster/cluster"
  retention_in_days = 7
}

resource "random_password" "password" {
  length           = 16
  special          = true
  min_lower        = 3
  min_numeric      = 3
  min_special      = 3
  min_upper        = 3
  override_special = "!&#$^<>-"
}

resource "aws_secretsmanager_secret" "cache_password" {
  name = "cache_password"

  depends_on = [random_password.password]
}

resource "aws_secretsmanager_secret_version" "cache_password" {
  secret_id     = aws_secretsmanager_secret.cache_password.id
  secret_string = random_password.password.result

  depends_on = [aws_secretsmanager_secret.cache_password]
}

resource "aws_elasticache_replication_group" "cache_cluster" {
  replication_group_id       = "redis-cluster"
  description                = "ElastiCache Redis cluster"
  node_type                  = var.node_type
  port                       = 6379
  parameter_group_name       = "default.redis7.cluster.on"
  automatic_failover_enabled = true
  apply_immediately          = true
  multi_az_enabled           = true
  # preferred_cache_cluster_azs = var.availability_zones
  num_node_groups         = length(var.availability_zones)
  replicas_per_node_group = 1

  auth_token                 = aws_secretsmanager_secret_version.cache_password.secret_string
  subnet_group_name          = aws_elasticache_subnet_group.cache_cluster.name
  security_group_ids         = [aws_security_group.cache_cluster.id]
  transit_encryption_enabled = true

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.cache_cluster.name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }

  depends_on = [
    aws_elasticache_subnet_group.cache_cluster,
    aws_security_group.cache_cluster,
    aws_secretsmanager_secret_version.cache_password,
    aws_cloudwatch_log_group.cache_cluster
  ]
}

data "aws_elasticache_cluster" "clusters" {
  count      = length(tolist(aws_elasticache_replication_group.cache_cluster.member_clusters))
  cluster_id = tolist(aws_elasticache_replication_group.cache_cluster.member_clusters)[count.index]
}

