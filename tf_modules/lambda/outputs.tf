output "lambda_functions" {
  description = "Lambda function ARNs and Names"
  value = {
    for fn in aws_lambda_function.lambda :
    element(split("/", fn.function_name), 1) => {
      name = element(split("/", fn.function_name), 1)
      arn  = fn.arn
    }
  }
}


output "security_group_id" {
  description = "The ID of the Lambda function"
  value       = aws_security_group.sg_lambda.id
}
