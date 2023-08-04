
/******************************************************
  RDS IAM role
******************************************************/
data "aws_iam_policy_document" "rds_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "rds_role" {
  name               = "iam_for_${var.engine}"
  assume_role_policy = data.aws_iam_policy_document.rds_role.json
  depends_on         = [data.aws_iam_policy_document.rds_role]
}

resource "aws_iam_role_policy_attachment" "rds_AmazonRDSDataFullAccess" {
  role       = aws_iam_role.rds_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess"
  depends_on = [aws_iam_role.rds_role]
}

# resource "aws_iam_role_policy_attachment" "rds_AmazonRDSEnhancedMonitoringRole" {
#   role       = aws_iam_role.rds_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonRDSEnhancedMonitoringRole"
#   depends_on = [aws_iam_role.rds_role]
# }

resource "aws_iam_role_policy_attachment" "rds_AmazonRDSPerformanceInsightsReadOnly" {
  role       = aws_iam_role.rds_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSPerformanceInsightsReadOnly"
  depends_on = [aws_iam_role.rds_role]
}

/******************************************************
  RDS Default Sunbet Group
******************************************************/
resource "aws_db_subnet_group" "default" {
  name       = var.subnet_group_name
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = var.subnet_group_name
  }
}

/******************************************************
  RDS Security Group
******************************************************/
resource "aws_security_group" "sg_rds" {
  name        = var.security_group_name
  description = "Allow all inbound for Mysql and all outbound within the VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Allow traffic to your database subnet 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"] # Restrict to traffic within the VPC
  }

  tags = {
    Name = "sg_rds"
  }
}

/******************************************************
  RDS Secret Manager
******************************************************/
resource "aws_kms_key" "key_rds" {
  description = "RDS user KMS Key"
}

/******************************************************
  RDS Multi-AZ Cluster
******************************************************/
resource "aws_rds_cluster" "cluster" {
  cluster_identifier = var.cluster_identifier
  # multi-zone attributes
  engine                    = var.engine
  storage_type              = var.storage_type
  allocated_storage         = 100
  iops                      = 1000
  db_cluster_instance_class = var.instance_class
  availability_zones        = var.availability_zones
  database_name             = var.database_name

  # master username and password
  manage_master_user_password   = true
  master_username               = var.master_username
  master_user_secret_kms_key_id = aws_kms_key.key_rds.key_id

  # vpc attributes
  vpc_security_group_ids = [aws_security_group.sg_rds.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name

  # snapshot attributes
  skip_final_snapshot = true
  apply_immediately   = true

  tags = {
    Name = var.cluster_identifier
  }

  enabled_cloudwatch_logs_exports = [
    "audit",
    "error",
    "general",
    "slowquery",
  ]

  depends_on = [aws_db_subnet_group.default, aws_security_group.sg_rds, aws_kms_key.key_rds]
}

data "aws_secretsmanager_secret_version" "db_secret" {
  secret_id = aws_rds_cluster.cluster.master_user_secret[0].secret_arn
}
