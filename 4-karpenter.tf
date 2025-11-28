# 1
module "karpenter" {
  depends_on = [module.eks]
  
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "21.9.0"

  cluster_name = "${local.env}-${local.eks_name}"

  namespace = "karpenter"

  create_node_iam_role = false
  node_iam_role_arn    = module.eks.eks_managed_node_groups["initial"].iam_role_arn
  create_access_entry = false

}

# 2
provider "aws" {
  alias  = "region_1"
  region = "us-east-1"
}

data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.region_1
}

resource "helm_release" "karpenter" {
  depends_on = [module.karpenter, module.eks.eks_managed_node_groups]

  namespace        = "karpenter"
  create_namespace = true

  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart               = "karpenter"
  version             = "1.6.1"

  values = [<<-EOT
    replicas: 1
    logLevel: "info"
    nodeSelector:
      nodeTypeClass: "initial"
    settings:
      clusterName: ${module.eks.cluster_name}
      clusterEndpoint: ${module.eks.cluster_endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
    serviceAccount:
      name: ${module.karpenter.service_account}
    serviceMonitor:
      enabled: true
      additionalLabels:
        release: "prometheus"
    controller:
      resources:
        requests:
          cpu: 100m
          memory: 256Mi
        limits:
          cpu: 500m
          memory: 1Gi
  EOT
  ]
}