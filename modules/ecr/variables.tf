variable "repo_name" {
  description = "Name of the ECR repository."
  type        = string
}

variable "scan_on_push" {
  description = "Enable image scanning on push."
  type        = bool
  default     = true
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting."
  type        = string
  default     = "IMMUTABLE"
}

variable "encryption_type" {
  description = "ECR encryption type (AES256 or KMS)."
  type        = string
  default     = "AES256"
}

variable "kms_key" {
  description = "KMS key ARN for ECR encryption when using KMS."
  type        = string
  default     = null
}

variable "lifecycle_policy" {
  description = "Lifecycle policy JSON for the ECR repository."
  type        = string
  default     = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Retain last 30 images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 30
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

variable "tags" {
  description = "Tags applied to the ECR repository."
  type        = map(string)
  default     = {}
}
