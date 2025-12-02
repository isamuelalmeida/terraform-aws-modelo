# Módulo EKS

Módulo wrapper para criação de cluster EKS usando o módulo oficial `terraform-aws-modules/eks/aws`.

## Recursos Criados

- EKS Control Plane
- Node Group gerenciado inicial
- IAM Roles e Policies
- Security Groups
- EKS Addons (kube-proxy, vpc-cni, coredns, pod-identity-agent, metrics-server, ebs-csi-driver)
- Encryption config para secrets

## Inputs

| Nome | Descrição | Tipo | Padrão | Obrigatório |
|------|-----------|------|--------|-------------|
| env | Nome do ambiente | string | - | Sim |
| name | Nome do projeto | string | - | Sim |
| eks_version | Versão do Kubernetes | string | - | Sim |
| vpc_id | ID da VPC | string | - | Sim |
| subnet_ids | IDs das subnets | list(string) | - | Sim |
| instance_types | Tipos de instância para node group inicial | list(string) | ["t3.medium", "t3a.medium"] | Não |
| capacity_type | Tipo de capacidade (SPOT/ON_DEMAND) | string | "SPOT" | Não |
| disk_size | Tamanho do disco em GB | number | 30 | Não |
| addon_versions | Versões dos addons do EKS | object | Ver valores padrão abaixo | Não |

## Outputs

| Nome | Descrição |
|------|-----------|
| cluster_name | Nome do cluster EKS |
| cluster_endpoint | Endpoint do cluster |
| cluster_certificate_authority_data | CA certificate do cluster |
| cluster_security_group_id | ID do security group do cluster |
| eks_managed_node_groups | Informações dos node groups |

## Exemplo de Uso

```hcl
module "eks" {
  source = "../../modules/eks"

  env         = "dev"
  name        = "demo"
  eks_version = "1.34"
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnets

  instance_types = ["t3.medium", "t3a.medium"]
  capacity_type  = "SPOT"
  disk_size      = 30
}
```

## Node Group Inicial

O módulo cria um node group inicial com:
- Min: 1 node
- Max: 3 nodes
- Desired: 1 node
- Label: `nodeTypeClass = initial`
- Usado para rodar Karpenter e outros componentes críticos

## Addons Instalados

- **kube-proxy**: Networking do Kubernetes
- **vpc-cni**: CNI plugin da AWS
- **coredns**: DNS interno do cluster
- **pod-identity-agent**: Autenticação de pods
- **metrics-server**: Métricas de recursos
- **ebs-csi-driver**: Volumes EBS persistentes
- **efs-csi-driver**: Volumes EFS compartilhados

### Versões Padrão dos Addons

```hcl
addon_versions = {
  kube_proxy             = "v1.34.1-eksbuild.2"
  vpc_cni                = "v1.20.5-eksbuild.1"
  coredns                = "v1.12.4-eksbuild.1"
  eks_pod_identity_agent = "v1.3.10-eksbuild.1"
  metrics_server         = "v0.8.0-eksbuild.5"
  aws_ebs_csi_driver     = "v1.53.0-eksbuild.1"
  aws_efs_csi_driver     = "v2.1.15-eksbuild.1"
}
```

### Customizando Versões por Ambiente

```hcl
module "eks" {
  source = "../../modules/eks"

  env         = "production"
  name        = "demo"
  eks_version = "1.34"
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnets

  addon_versions = {
    kube_proxy             = "v1.35.0-eksbuild.1"
    vpc_cni                = "v1.21.0-eksbuild.1"
    coredns                = "v1.13.0-eksbuild.1"
    eks_pod_identity_agent = "v1.4.0-eksbuild.1"
    metrics_server         = "v0.9.0-eksbuild.1"
    aws_ebs_csi_driver     = "v1.54.0-eksbuild.1"
    aws_efs_csi_driver     = "v2.2.0-eksbuild.1"
  }
}
```
