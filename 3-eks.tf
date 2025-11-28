module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.9.0"

  name    = "${local.env}-${local.eks_name}"
  kubernetes_version = local.eks_version

  endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_cluster_creator_admin_permissions = true

  addons = {
    kube-proxy = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      addon_version = "v1.34.1-eksbuild.2"
    }
    vpc-cni = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      addon_version = "v1.20.5-eksbuild.1"
      before_compute               = true
    }
    coredns = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      addon_version     = "v1.12.4-eksbuild.1"
    }
    eks-pod-identity-agent = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      addon_version     = "v1.3.10-eksbuild.1"
      before_compute               = true
    }
    metrics-server = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      addon_version     = "v0.8.0-eksbuild.5"
    }
  }

  eks_managed_node_groups = {
    initial = {
      instance_types = ["t3.medium", "t3a.medium"]

      min_size     = 2
      max_size     = 10
      desired_size = 2

      capacity_type  = "SPOT"
      disk_size      = 30

      labels = {
        role = "general"
      }
    }
  }

  encryption_config = {
    resources = ["secrets"]
  }

  tags = {
    Environment = local.env
    Terraform   = "true"
  }
}
