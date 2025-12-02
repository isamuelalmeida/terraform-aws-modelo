# Módulo EFS

Módulo wrapper para criação de Amazon Elastic File System (EFS) usando o módulo oficial `terraform-aws-modules/efs/aws`.

## Recursos Criados

- EFS File System com criptografia habilitada
- Mount Targets em múltiplas subnets
- Security Group permitindo acesso NFS dos nodes EKS
- Lifecycle Policy para transição para Infrequent Access

## Inputs

| Nome | Descrição | Tipo | Padrão | Obrigatório |
|------|-----------|------|--------|-------------|
| env | Nome do ambiente | string | - | Sim |
| name | Nome do projeto | string | - | Sim |
| vpc_id | ID da VPC | string | - | Sim |
| subnet_ids | IDs das subnets para mount targets | list(string) | - | Sim |
| eks_node_security_group_id | Security group dos nodes EKS | string | - | Sim |
| performance_mode | Modo de performance (generalPurpose/maxIO) | string | "generalPurpose" | Não |
| throughput_mode | Modo de throughput (bursting/provisioned) | string | "bursting" | Não |
| transition_to_ia | Política de transição para IA | string | "AFTER_30_DAYS" | Não |
| tags | Tags adicionais | map(string) | {} | Não |

## Outputs

| Nome | Descrição |
|------|-----------|
| efs_id | ID do EFS file system |
| efs_arn | ARN do EFS file system |
| efs_dns_name | DNS name do EFS file system |
| security_group_id | ID do security group do EFS |

## Exemplo de Uso

```hcl
module "efs" {
  source = "../../modules/efs"

  env                        = "dev"
  name                       = "demo"
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.private_subnets
  eks_node_security_group_id = module.eks.node_security_group_id

  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
}
```

## Uso no Kubernetes

Após criar o EFS, use o ID no StorageClass:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: efs-sc
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: fs-xxxxx  # Output: efs_id
  directoryPerms: "700"
```

## Características

- **Criptografia**: Habilitada por padrão
- **Performance Mode**: General Purpose (padrão) ou Max I/O
- **Throughput Mode**: Bursting (padrão) ou Provisioned
- **Lifecycle Policy**: Transição para IA após 30 dias (padrão)
- **Alta Disponibilidade**: Mount targets em múltiplas AZs

## Segurança

- Security group permite apenas tráfego NFS (porta 2049) dos nodes EKS
- Criptografia em repouso habilitada
- Criptografia em trânsito suportada pelo EFS CSI Driver
