
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.83.0, < 7.0.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

# Use the existing default VPC.
data "aws_vpc" "default" {
  default = true
}

# Discover the subnets belonging to that VPC.
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "eks" {
  enable_irsa = false
  source      = "terraform-aws-modules/eks/aws"
  version     = "~> 20.0"

  cluster_name    = "capstone-voting-eks"
  cluster_version = "1.34"

  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.default.ids


  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
  # Give the identity running Terraform admin access
  # to this Kubernetes cluster.
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    capstone = {
      min_size     = 1
      max_size     = 1
      desired_size = 1

      instance_types = ["t3.small"]
    }
  }
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_region" {
  value = "eu-north-1"
}

output "kubectl_update_command" {
  value = "aws eks update-kubeconfig --region eu-north-1 --name ${module.eks.cluster_name}"
}
