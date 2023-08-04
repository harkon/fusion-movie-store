provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

module "vpc" {
  source             = "../../tf_modules/vpc"
  region             = var.region
  name               = "dev_vpc"
  cidr               = "10.0.0.0/16"
  availability_zones = var.availability_zones
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  eks_cluster_name   = var.eks_cluster_name
}

module "ecr" {
  source           = "../../tf_modules/ecr"
  lambda_repo      = var.lambda_repo
  service_repo     = var.service_repo
  tags             = var.tags
  image_mutability = var.image_mutability
}

module "rds_cluster" {
  source             = "../../tf_modules/rds"
  cluster_identifier = "mysql-cluster"
  engine             = "mysql"
  storage_type       = "io1"
  allocated_storage  = 100
  iops               = 1000
  instance_class     = "db.m5d.large"
  database_name      = "moviesdb"
  master_username    = "dbuser"
  private_subnet_ids = module.vpc.private_subnets_ids
  availability_zones = var.availability_zones
  vpc_id             = module.vpc.vpc_id

  depends_on = [module.vpc]
}

module "elasticache" {
  source              = "../../tf_modules/redis"
  availability_zones  = var.availability_zones
  private_subnets_ids = module.vpc.private_subnets_ids
  vpc_id              = module.vpc.vpc_id

  depends_on = [module.vpc, module.rds_cluster]
}

module "lambda" {
  source              = "../../tf_modules/lambda"
  region              = var.region
  account_id          = data.aws_caller_identity.current.account_id
  secret_arn          = module.rds_cluster.secret_arn
  kms_key_id          = module.rds_cluster.kms_key_id
  bucket_name         = var.bucket_name
  lambda_repo         = var.lambda_repo
  repository_urls     = module.ecr.repository_urls
  private_subnets_ids = module.vpc.private_subnets_ids
  environment_variables = merge(var.environment_variables, {
    DB_USER        = module.rds_cluster.username,
    DB_PASSWORD    = module.rds_cluster.master_password
    DB_HOST        = module.rds_cluster.host,
    DB_NAME        = module.rds_cluster.database,
    REDIS_HOST     = module.elasticache.configuration_endpoint,
    REDIS_PORT     = module.elasticache.port,
    REDIS_PASSWORD = module.elasticache.password,
    STARTUP_NODES  = module.elasticache.redis_shard_endpoints
  })
  vpc_id = module.vpc.vpc_id

  depends_on = [module.vpc, module.ecr, module.rds_cluster, module.elasticache]
}

module "s3" {
  source              = "../../tf_modules/s3"
  bucket_name         = var.bucket_name
  function_name       = module.lambda.lambda_functions[var.s3_lambda_function_name].name
  lambda_function_arn = module.lambda.lambda_functions[var.s3_lambda_function_name].arn

  depends_on = [module.lambda]
}

module "eks" {
  source              = "../../tf_modules/eks"
  account_id          = data.aws_caller_identity.current.account_id
  cluster_name        = var.eks_cluster_name
  private_subnets_ids = module.vpc.private_subnets_ids
  node_desired_size   = length(var.availability_zones)
  node_max_size       = length(var.availability_zones) * 2
  node_min_size       = length(var.availability_zones)
  vpc_id              = module.vpc.vpc_id

  depends_on = [module.vpc, module.ecr, module.rds_cluster]
}

/**
 * This module is used to deploy the k8s resources
 * required for the application.
 */
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name]
    command     = "aws"
  }
}

module "k8s" {
  source             = "../../tf_modules/k8s"
  rds_secret_arn     = module.rds_cluster.secret_arn
  db_host            = module.rds_cluster.host
  db_name            = module.rds_cluster.database
  redis_host         = module.elasticache.configuration_endpoint
  redis_port         = module.elasticache.port
  redis_password     = module.elasticache.password
  service_repo       = var.service_repo
  repository_urls    = module.ecr.repository_urls
  availability_zones = var.availability_zones

  depends_on = [module.ecr, module.elasticache, module.rds_cluster, module.eks]
}


module "api" {
  source            = "../../tf_modules/api"
  region            = var.region
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnets_ids
  load_balancer_arn = "arn:aws:elasticloadbalancing:${var.region}:${data.aws_caller_identity.current.account_id}:loadbalancer/net/ad412e65959c4442d9fe73bb499aa9f0/d4a4cbb31453109f"
  load_balancer_dns = module.k8s.load_balancer_ingress_hostname["fusion-movie-store/movie-store-api"]

  depends_on = [module.vpc, module.k8s]
}
