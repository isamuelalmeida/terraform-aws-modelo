module "vpc" {
  source = "../../modules/vpc"

  env          = var.env
  name         = var.name
  vpc_cidr     = var.vpc_cidr
  azs          = [var.zone1, var.zone2]
  cluster_name = "${var.env}-${var.name}"

  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
}

module "eks" {
  source = "../../modules/eks"

  env         = var.env
  name        = var.name
  eks_version = var.eks_version
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnets
}

module "kubernetes_addons" {
  source = "../../modules/kubernetes-addons"

  env                     = var.env
  name                    = var.name
  cluster_name            = module.eks.cluster_name
  cluster_endpoint        = module.eks.cluster_endpoint
  eks_managed_node_groups = module.eks.eks_managed_node_groups
  vpc_id                  = module.vpc.vpc_id
  nodepool_config         = var.eks_config.default
}
