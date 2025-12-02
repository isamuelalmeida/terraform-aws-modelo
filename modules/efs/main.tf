module "efs" {
  source  = "terraform-aws-modules/efs/aws"
  version = "~> 2.0.0"

  name           = "${var.env}-${var.name}"
  creation_token = "${var.env}-${var.name}"
  encrypted      = true

  performance_mode = var.performance_mode
  throughput_mode  = var.throughput_mode

  lifecycle_policy = {
    transition_to_ia = var.transition_to_ia
  }

  mount_targets = {
    for idx, subnet_id in var.subnet_ids : "mount-${idx}" => {
      subnet_id = subnet_id
    }
  }

  security_group_vpc_id = var.vpc_id
  security_group_ingress_rules = {
    eks_nodes = {
      description                  = "NFS from EKS nodes"
      referenced_security_group_id = var.eks_node_security_group_id
    }
  }

  tags = merge(
    {
      Environment = var.env
      Terraform   = "true"
    },
    var.tags
  )
}
