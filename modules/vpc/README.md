# Módulo VPC

Módulo wrapper para criação de VPC usando o módulo oficial `terraform-aws-modules/vpc/aws`.

## Recursos Criados

- VPC com DNS habilitado
- Subnets públicas e privadas em múltiplas AZs
- Internet Gateway
- NAT Gateway (configurável: single ou múltiplo)
- Route Tables
- Tags para integração com EKS e Karpenter

## Inputs

| Nome | Descrição | Tipo | Obrigatório |
|------|-----------|------|-------------|
| env | Nome do ambiente | string | Sim |
| name | Nome do projeto | string | Sim |
| vpc_cidr | CIDR block da VPC | string | Sim |
| azs | Lista de Availability Zones | list(string) | Sim |
| private_subnets | Lista de CIDRs para subnets privadas | list(string) | Sim |
| public_subnets | Lista de CIDRs para subnets públicas | list(string) | Sim |
| cluster_name | Nome do cluster EKS para tagging | string | Sim |

## Outputs

| Nome | Descrição |
|------|-----------|
| vpc_id | ID da VPC criada |
| private_subnets | IDs das subnets privadas |
| public_subnets | IDs das subnets públicas |
| nat_gateway_ids | IDs dos NAT Gateways |

## Exemplo de Uso

```hcl
module "vpc" {
  source = "../../modules/vpc"

  env          = "dev"
  name         = "demo"
  vpc_cidr     = "10.200.0.0/16"
  azs          = ["us-east-2a", "us-east-2b"]
  cluster_name = "dev-demo"

  private_subnets = ["10.200.0.0/19", "10.200.32.0/19"]
  public_subnets  = ["10.200.64.0/19", "10.200.96.0/19"]
}
```

## Tags Aplicadas

- Subnets públicas: `kubernetes.io/role/elb = 1`
- Subnets privadas: `kubernetes.io/role/internal-elb = 1`, `karpenter.sh/discovery`
- Todas as subnets: `kubernetes.io/cluster/<cluster_name> = owned`
