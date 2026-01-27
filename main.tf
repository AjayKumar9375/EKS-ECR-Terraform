provider "aws" {
  region = var.aws_region
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
    },
    var.tags
  )
}

module "vpc" {
  source          = "./modules/vpc"
  name            = "${local.name_prefix}-vpc"
  cidr            = var.vpc_cidr
  azs             = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets
  cluster_name    = "${local.name_prefix}-eks"
  tags            = local.common_tags
}

module "eks" {
  source          = "./modules/eks"
  cluster_name    = "${local.name_prefix}-eks"
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  node_group_size = {
    desired = var.node_desired_size
    min     = var.node_min_size
    max     = var.node_max_size
  }
  node_instance_types = var.node_instance_types
  tags                = local.common_tags
}

module "ecr" {
  source    = "./modules/ecr"
  repo_name = var.ecr_repo_name != "" ? var.ecr_repo_name : local.name_prefix
  tags      = local.common_tags
}
