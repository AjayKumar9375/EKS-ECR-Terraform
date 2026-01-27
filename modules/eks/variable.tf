variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
}


variable "vpc_id" {
  description = "VPC ID for the EKS cluster."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the EKS cluster."
  type        = list(string)
}

variable "node_instance_types" {
  description = "Instance types for the managed node group."
  type        = list(string)
  default     = ["t3.micro"]
}

variable "node_group_size" {
  description = "Sizing configuration for the managed node group."
  type = object({
    desired = number
    min     = number
    max     = number
  })
  default = {
    desired = 2
    min     = 1
    max     = 3
  }
}

variable "cluster_endpoint_public_access" {
  description = "Whether the EKS cluster endpoint should be publicly accessible."
  type        = bool
  default     = true
}

variable "cluster_addons" {
  description = "EKS add-ons to enable on the cluster."
  type        = map(any)
  default = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }
}

variable "tags" {
  description = "Tags applied to EKS resources."
  type        = map(string)
  default     = {}
}
