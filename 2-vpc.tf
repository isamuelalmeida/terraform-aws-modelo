module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.5.1"

  name = "${local.env}-vpc"
  cidr = "10.200.0.0/16"

  azs             = [local.zone1, local.zone2]
  private_subnets = ["10.200.0.0/19", "10.200.32.0/19"]
  public_subnets  = ["10.200.64.0/19", "10.200.96.0/19"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  map_public_ip_on_launch = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                           = "1"
    "kubernetes.io/cluster/${local.env}-${local.name}" = "owned"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"                  = "1"
    "kubernetes.io/cluster/${local.env}-${local.name}" = "owned"
    "karpenter.sh/discovery"                           = "${local.env}-${local.name}"
  }

  tags = {
    Environment = local.env
    Terraform   = "true"
  }
}
