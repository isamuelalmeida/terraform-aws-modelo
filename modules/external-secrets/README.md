# External Secrets Operator Module

Módulo para instalação e configuração do External Secrets Operator (ESO) no EKS usando Pod Identity.

## Funcionalidades

- Instalação do External Secrets Operator via Helm
- Configuração de IAM Role com Pod Identity (não IRSA)
- ClusterSecretStore para AWS Secrets Manager
- Suporte a múltiplas secrets via `dataFrom.extract`

## Uso

```hcl
module "external_secrets" {
  source = "../../modules/external-secrets"

  env          = var.env
  name         = var.name
  cluster_name = module.eks.cluster_name
  aws_region   = "us-east-1"
  
  secrets_arns = [
    "arn:aws:secretsmanager:us-east-1:123456789012:secret:prod/minha-app-*"
  ]

  tags = var.common_tags
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| env | Environment name | string | - | yes |
| name | Project name | string | - | yes |
| cluster_name | EKS Cluster name | string | - | yes |
| aws_region | AWS Region for Secrets Manager | string | - | yes |
| secrets_arns | List of Secrets Manager ARNs | list(string) | ["*"] | no |
| chart_version | ESO Helm chart version | string | 1.1.0 | no |
| create_cluster_secret_store | Create ClusterSecretStore | bool | true | no |
| tags | Tags to apply | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| iam_role_arn | ARN of the IAM role |
| namespace | Namespace where ESO is installed |
| cluster_secret_store_name | Name of the ClusterSecretStore (if created) |
| chart_version | Version of the ESO Helm chart |
