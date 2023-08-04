/******************************************************
  Lambda IAM role
******************************************************/
data "aws_iam_policy_document" "lambda_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect = "Allow"
    sid    = ""
  }
}
# lambda role
resource "aws_iam_role" "lambda_role" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_role.json
  depends_on         = [data.aws_iam_policy_document.lambda_role]
}

resource "aws_iam_role_policy_attachment" "attach_execution_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  depends_on = [aws_iam_role.lambda_role]
}

# s3_access policy
data "aws_iam_policy_document" "s3_access" {
  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.bucket_name}", "arn:aws:s3:::${var.bucket_name}/*"]
  }
}

resource "aws_iam_policy" "s3_access" {
  name       = "${aws_iam_role.lambda_role.name}-s3"
  policy     = data.aws_iam_policy_document.s3_access.json
  depends_on = [data.aws_iam_policy_document.s3_access]
}

resource "aws_iam_role_policy_attachment" "s3_access_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.s3_access.arn
  depends_on = [aws_iam_role.lambda_role, aws_iam_policy.s3_access]
}

# lambda logging policy
data "aws_iam_policy_document" "lambda_logging" {
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "${aws_iam_role.lambda_role.name}-logging"
  description = "Provides permissions to create and interact with CloudWatch logs"
  policy      = data.aws_iam_policy_document.lambda_logging.json
  depends_on  = [aws_iam_role.lambda_role, data.aws_iam_policy_document.lambda_logging]
}

resource "aws_iam_role_policy_attachment" "lambda_logging_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
  depends_on = [aws_iam_role.lambda_role, aws_iam_policy.lambda_logging]
}

# KMS
data "aws_iam_policy_document" "lambda_kms" {
  statement {
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = ["arn:aws:kms:${var.region}:${var.account_id}:key/${var.kms_key_id}"]
  }
}

resource "aws_iam_policy" "lambda_kms" {
  name        = "${aws_iam_role.lambda_role.name}-kms"
  description = "Allows access to specific KMS key"
  policy      = data.aws_iam_policy_document.lambda_kms.json
}

resource "aws_iam_role_policy_attachment" "lambda_allow_kms_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_kms.arn
  depends_on = [aws_iam_role.lambda_role, aws_iam_policy.lambda_kms]
}

# secrets manager policy
data "aws_iam_policy_document" "lambda_sm" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [var.secret_arn]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "lambda_sm" {
  name        = "${aws_iam_role.lambda_role.name}-secrets-manager"
  description = "Allows access to specific secret in Secrets Manager"
  policy      = data.aws_iam_policy_document.lambda_sm.json
}

resource "aws_iam_role_policy_attachment" "lambda_allow_secrets_manager_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_sm.arn
  depends_on = [aws_iam_role.lambda_role, aws_iam_policy.lambda_sm]
}

/******************************************************
  Security Group for Lambda function
******************************************************/
resource "aws_security_group" "sg_lambda" {
  name        = "sg_lambda"
  description = "Allow inbound traffic from S3 and outbound traffic to RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"           # Allow all traffic
    cidr_blocks = ["10.0.0.0/8"] # Restrict to traffic within the VPC
  }

  # This egress rule allows traffic to your database subnet
  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Allow traffic to your database subnet
  }

    # This egress rule allows traffic to the redis subnet
  egress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Allow traffic to your database subnet
  }

  # This egress rule allows all outbound traffic, 
  # which is necessary for the Lambda to access the internet (through the NAT Gateway)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_lambda"
  }
}

/******************************************************
  Get image digest
******************************************************/
data "external" "lambda_digest" {
  for_each = toset(var.lambda_repo)
  program  = ["bash", "../../utils/get-digest.sh", each.key]
}

/******************************************************
  Lambda function
******************************************************/
resource "aws_lambda_function" "lambda" {
  for_each      = toset(var.lambda_repo)
  function_name = element(split("/", each.key), 1)
  image_uri     = "${lookup(var.repository_urls, each.key, "Not found")}@${data.external.lambda_digest[each.key].result["digest"]}"
  role          = aws_iam_role.lambda_role.arn

  package_type = "Image"
  timeout      = 5

  environment {
    variables = var.environment_variables
  }

  vpc_config {
    subnet_ids         = var.private_subnets_ids
    security_group_ids = [aws_security_group.sg_lambda.id]
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [data.external.lambda_digest, aws_iam_role.lambda_role, aws_security_group.sg_lambda]
}


