# External Secrets Operator Module

Módulo para criação de recursos AWS necessários para o External Secrets Operator (ESO) no EKS usando Pod Identity.

## Funcionalidades

- Criação de IAM Role e Policy para acesso ao AWS Secrets Manager
- Configuração de Pod Identity Association
- Criação de Namespace e ServiceAccount

**Nota:** O Helm chart do External Secrets Operator e o ClusterSecretStore devem ser gerenciados pelo ArgoCD.

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
| namespace | Namespace where ESO should be installed |
| service_account_name | Name of the ServiceAccount |
