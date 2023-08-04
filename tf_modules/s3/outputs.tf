output "bucket_id" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.data_bucket.id
}

output "bucket_arn" {
  description = "value of the bucket arn"
  value       = aws_s3_bucket.data_bucket.arn
}