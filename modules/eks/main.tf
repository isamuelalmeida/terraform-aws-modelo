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
      addon_version               = var.addon_versions.kube_proxy
    }
    vpc-cni = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      addon_version               = var.addon_versions.vpc_cni
      before_compute              = true
    }
    coredns = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      addon_version               = var.addon_versions.coredns
    }
    eks-pod-identity-agent = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      addon_version               = var.addon_versions.eks_pod_identity_agent
      before_compute              = true
    }
    metrics-server = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      addon_version               = var.addon_versions.metrics_server
    }
  }

  eks_managed_node_groups = {
    eks-node-initial = {
      instance_types = var.instance_types

      min_size     = 1
      max_size     = 3
      desired_size = 2

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

  tags = merge(
    {
      Environment              = var.env
      Terraform                = "true"
      "karpenter.sh/discovery" = "${var.env}-${var.name}"
    },
    var.tags
  )
  security_group_tags = merge(
    {
      "karpenter.sh/discovery" = "${var.env}-${var.name}"
    },
    var.tags
  )
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = var.addon_versions.aws_ebs_csi_driver
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    module.eks,
    aws_eks_pod_identity_association.ebs_csi_driver
  ]
}

resource "aws_eks_addon" "efs_csi_driver" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-efs-csi-driver"
  addon_version            = var.addon_versions.aws_efs_csi_driver
  service_account_role_arn = aws_iam_role.efs_csi_driver.arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    module.eks,
    aws_eks_pod_identity_association.efs_csi_driver
  ]
}
