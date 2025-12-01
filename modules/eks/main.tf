module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.9.0"

  name               = "${var.env}-${var.name}"
  kubernetes_version = var.eks_version

  endpoint_public_access = true

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  enable_cluster_creator_admin_permissions = true

  addons = {
    kube-proxy = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      addon_version               = "v1.34.1-eksbuild.2"
    }
    vpc-cni = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      addon_version               = "v1.20.5-eksbuild.1"
      before_compute              = true
    }
    coredns = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      addon_version               = "v1.12.4-eksbuild.1"
    }
    eks-pod-identity-agent = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      addon_version               = "v1.3.10-eksbuild.1"
      before_compute              = true
    }
    metrics-server = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      addon_version               = "v0.8.0-eksbuild.5"
    }
    aws-ebs-csi-driver = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      addon_version               = "v1.53.0-eksbuild.1"
      service_account_role_arn    = aws_iam_role.ebs_csi_driver.arn
    }
  }

  eks_managed_node_groups = {
    eks-node-initial = {
      instance_types = var.instance_types

      min_size     = 1
      max_size     = 3
      desired_size = 1

      capacity_type = var.capacity_type
      disk_size     = var.disk_size

      labels = {
        nodeTypeClass = "initial"
      }
    }
  }

  encryption_config = {
    resources = ["secrets"]
  }

  tags = {
    Environment              = var.env
    Terraform                = "true"
    "karpenter.sh/discovery" = "${var.env}-${var.name}"
  }
  security_group_tags = {
    "karpenter.sh/discovery" = "${var.env}-${var.name}"
  }
}
