/******************************************************
  S3 Bucket
******************************************************/
resource "aws_s3_bucket" "data_bucket" {
  bucket = var.bucket_name
  acl = "private"

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_versioning" "data_bucket" {
  bucket = aws_s3_bucket.data_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
  depends_on = [aws_s3_bucket.data_bucket]
}

resource "aws_s3_bucket_ownership_controls" "data_bucket" {
  bucket = aws_s3_bucket.data_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
  depends_on = [aws_s3_bucket.data_bucket]
}

# resource "aws_s3_bucket_acl" "data_bucket" {
#   bucket = aws_s3_bucket.data_bucket.id
#   acl    = "private"

#   depends_on = [aws_s3_bucket_ownership_controls.data_bucket]
# }

resource "aws_s3_bucket_notification" "data_bucket" {
  bucket = aws_s3_bucket.data_bucket.id

  lambda_function {
    lambda_function_arn = var.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_s3_bucket.data_bucket]
}

/******************************************************
  Lambda Permission for S3 Bucket
******************************************************/
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.data_bucket.arn
  depends_on    = [aws_s3_bucket.data_bucket]
}
