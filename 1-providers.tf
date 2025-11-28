provider "aws" {
  region = local.region
}

terraform {
  required_version = ">= 1.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.22"
    }
  }
}

## Helm
# data "aws_eks_cluster" "eks" {
#   name = module.eks.cluster_name
# }

# data "aws_eks_cluster_auth" "eks" {
#   name = module.eks.cluster_name
# }

# provider "helm" {
#   kubernetes = {
#     host                   = data.aws_eks_cluster.eks.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
#     token                  = data.aws_eks_cluster_auth.eks.token
#   }
# }