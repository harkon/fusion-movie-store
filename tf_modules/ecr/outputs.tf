output "repository_urls" {
  description = "The URLs of the repositories"
  value       = { for repo in aws_ecr_repository.ecr : repo.name => repo.repository_url }
}
