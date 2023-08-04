locals {
  repositories = concat(
    sort(var.service_repo),
    sort(var.lambda_repo),
  )
}


resource "aws_ecr_repository" "ecr" {
  for_each             = toset(local.repositories)
  name                 = each.key
  image_tag_mutability = var.image_mutability
  encryption_configuration {
    encryption_type = var.encrypt_type
  }
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = var.tags
}
