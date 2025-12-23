# External Secrets Operator Module

Módulo para criação de recursos AWS necessários para o External Secrets Operator (ESO) no EKS usando Pod Identity.

## Funcionalidades

- Criação de IAM Role e Policy para acesso ao AWS Secrets Manager
- Configuração de Pod Identity Association

**Nota:** O Helm chart do External Secrets Operator e o ClusterSecretStore devem ser gerenciados pelo ArgoCD.

## Uso

```hcl
module "external_secrets" {
  source = "../../modules/external-secrets"

  env          = var.env
  name         = var.name
  cluster_name = module.eks.cluster_name
  
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
| secrets_arns | List of Secrets Manager ARNs | list(string) | ["*"] | no |
| tags | Tags to apply | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| iam_role_arn | ARN of the IAM role |
