resource "aws_ecr_repository" "repository" {
  name = var.repo_name

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  image_tag_mutability = var.image_tag_mutability

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.encryption_type == "KMS" ? var.kms_key : null
  }

  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "repository" {
  repository = aws_ecr_repository.repository.name
  policy     = var.lifecycle_policy
}
