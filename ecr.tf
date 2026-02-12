resource "aws_ecr_repository" "lambda_api" {
  name                 = "lambda-api-${var.env}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "ecr_repo_url" {
  description = "ECR repository URL (no tag)"
  value       = aws_ecr_repository.lambda_api.repository_url
}