module "vpc" {
  source = "../../modules/vpc"

  env                = var.env
  name               = var.name
  vpc_cidr           = var.vpc_cidr
  azs                = [var.zone1, var.zone2]
  cluster_name       = "${var.env}-${var.name}"
  single_nat_gateway = var.single_nat_gateway

  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  tags = var.common_tags
}

module "eks" {
  source = "../../modules/eks"

  env         = var.env
  name        = var.name
  eks_version = var.eks_version
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnets

  node_group_min_size     = var.node_group_min_size
  node_group_max_size     = var.node_group_max_size
  node_group_desired_size = var.node_group_desired_size

  tags = var.common_tags
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

  efs_storage_classes = {
    efs = {
      efs_id = module.efs.efs_id
    }
  }

  depends_on = [module.eks]
}

module "efs" {
  source = "../../modules/efs"

  env        = var.env
  name       = var.name
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_node_security_group_id = module.eks.node_security_group_id

  tags = var.common_tags
}

module "external_secrets" {
  source = "../../modules/external-secrets"

  env          = var.env
  name         = var.name
  cluster_name = module.eks.cluster_name
  aws_region   = var.region
  secrets_arns = ["*"]

  tags = var.common_tags

  depends_on = [module.eks, module.kubernetes_addons]
}

module "argocd" {
  source = "../../modules/argocd"

  env  = var.env
  name = var.name

  tags = var.common_tags

  depends_on = [module.eks, module.kubernetes_addons, module.external_secrets]
}

module "github_oidc" {
  count  = length(var.github_repositories) > 0 ? 1 : 0
  source = "../../modules/github-oidc"

  env  = var.env
  name = var.name

  github_repositories = var.github_repositories

  tags = var.common_tags
}