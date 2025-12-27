data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "eks-policy" {
  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
    ]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "eks-policy" {
  name        = "eks-ecr-policy-${data.aws_caller_identity.current.account_id}"
  description = "EKS ECR Access Policy"
  policy      = data.aws_iam_policy_document.eks-policy.json

}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.3"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  eks_managed_node_groups = {
    default = {
      desired_size   = 2
      max_size       = 3
      min_size       = 1
      instance_types = ["t3.micro"]
    }
  }

  enable_irsa = true
}
