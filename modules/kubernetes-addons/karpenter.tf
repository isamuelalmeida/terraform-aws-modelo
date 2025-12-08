module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "21.9.0"

  cluster_name = var.cluster_name

  namespace = "karpenter"

  create_node_iam_role = false
  node_iam_role_arn    = var.eks_managed_node_groups["eks-node-initial"].iam_role_arn
  create_access_entry  = false
}
