############################
# IAM ROLE PARA POD IDENTITY
############################

data "aws_iam_policy_document" "pod_identity_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eso" {
  name               = "${var.env}-${var.name}-external-secrets-role"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust.json

  tags = var.tags
}

data "aws_iam_policy_document" "eso_policy" {
  statement {
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
    ]
    resources = var.secrets_arns
  }
}

resource "aws_iam_policy" "eso" {
  name   = "${var.env}-${var.name}-external-secrets-policy"
  policy = data.aws_iam_policy_document.eso_policy.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "eso_attach" {
  role       = aws_iam_role.eso.name
  policy_arn = aws_iam_policy.eso.arn
}

############################
# NAMESPACE + SERVICEACCOUNT
############################

resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = "external-secrets"
  }
}

resource "kubernetes_service_account" "external_secrets" {
  metadata {
    name      = "external-secrets"
    namespace = kubernetes_namespace.external_secrets.metadata[0].name
  }
}

############################
# POD IDENTITY ASSOCIATION
############################

resource "aws_eks_pod_identity_association" "eso" {
  cluster_name    = var.cluster_name
  namespace       = kubernetes_namespace.external_secrets.metadata[0].name
  service_account = kubernetes_service_account.external_secrets.metadata[0].name
  role_arn        = aws_iam_role.eso.arn
}

############################
# HELM RELEASE
############################

resource "helm_release" "external_secrets" {
  depends_on = [aws_eks_pod_identity_association.eso]

  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = var.chart_version
  namespace        = kubernetes_namespace.external_secrets.metadata[0].name
  create_namespace = false

  values = [<<-EOT
    installCRDs: true
    serviceAccount:
      create: false
      name: ${kubernetes_service_account.external_secrets.metadata[0].name}
  EOT
  ]
}

############################
# CLUSTER SECRET STORE
############################

resource "kubectl_manifest" "secretstore_aws" {
  count = var.create_cluster_secret_store ? 1 : 0

  depends_on = [helm_release.external_secrets]

  yaml_body = <<-YAML
    apiVersion: external-secrets.io/v1
    kind: ClusterSecretStore
    metadata:
      name: aws-secrets-manager
    spec:
      provider:
        aws:
          service: SecretsManager
          region: ${var.aws_region}
  YAML
}
