
/******************************************************
  EKS Cluster IAM role
******************************************************/
data "aws_iam_policy_document" "eks_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_role" {
  name               = "iam_for_eks"
  assume_role_policy = data.aws_iam_policy_document.eks_role.json
  depends_on         = [data.aws_iam_policy_document.eks_role]
}

resource "aws_iam_role_policy_attachment" "eks_role-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
  depends_on = [aws_iam_role.eks_role]
}

resource "aws_iam_role_policy_attachment" "eks_role-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_role.name
  depends_on = [aws_iam_role.eks_role]
}

resource "aws_cloudwatch_log_group" "default" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 7
}

/******************************************************
  Security Group for EKS
******************************************************/
resource "aws_security_group" "sg_eks" {
  name        = "sg_eks"
  description = "Allow inbound traffic from the VPC and outbound traffic to RDS and ElastiCache"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"           # Allow all traffic
    cidr_blocks = ["10.0.0.0/8"] # Restrict to traffic within the VPC
  }

  # This egress rule allows traffic to the database and cache subnets
  egress {
    from_port   = var.rds_port
    to_port     = var.rds_port
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Allow traffic to the database subnet
  }


  egress {
    from_port   = var.redis_port
    to_port     = var.redis_port
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Allow traffic to the cache subnet
  }

  tags = {
    Name = "sg_eks"
  }
}

/******************************************************
  EKS Cluster
******************************************************/
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.sg_eks.id]
    subnet_ids              = var.private_subnets_ids
  }

  kubernetes_network_config {
    service_ipv4_cidr = "10.100.0.0/16"
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager"]

  depends_on = [aws_iam_role.eks_role, aws_cloudwatch_log_group.default]
}

/******************************************************
  EKS Node Group IAM role
******************************************************/
data "aws_iam_policy_document" "eks_ng_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "eks_ng_role" {
  name               = "${aws_iam_role.eks_role.name}_worker_node"
  assume_role_policy = data.aws_iam_policy_document.eks_ng_role.json
  depends_on         = [aws_iam_role.eks_role, data.aws_iam_policy_document.eks_ng_role]
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eks_ng_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  depends_on = [aws_iam_role.eks_ng_role]
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eks_ng_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  depends_on = [aws_iam_role.eks_ng_role]
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.eks_ng_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  depends_on = [aws_iam_role.eks_ng_role]
}

/******************************************************
  EKS Node Group
******************************************************/
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "default"
  node_role_arn   = aws_iam_role.eks_ng_role.arn
  subnet_ids      = var.private_subnets_ids

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_iam_role.eks_ng_role,
  ]
}
