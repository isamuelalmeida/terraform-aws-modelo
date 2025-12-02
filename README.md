## Estrutura do Projeto

```
.
├── modules/                  # Módulos Reutilizáveis
│   ├── vpc/                  # Lógica de Rede
│   ├── eks/                  # Lógica do Cluster EKS
│   ├── efs/                  # Amazon EFS File Systems
│   └── kubernetes-addons/    # Karpenter, LBC, StorageClasses
├── environments/             # Configurações por Ambiente
│   ├── dev/
│   │   ├── main.tf           # Instanciação dos módulos
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf      # Configuração do Backend/Provider
│   │   └── terraform.tfvars  # Valores específicos
│   ├── staging/
│   └── production/
└── README.md
```

## Pré-requisitos

- Terraform >= 1.14
- AWS CLI v2 configurado
- kubectl instalado
- helm instalado

## Como Usar

### 1. Escolha o Ambiente

Navegue até o diretório do ambiente desejado:

```bash
cd environments/dev  # ou staging, production
```

### 2. Inicialize o Terraform

```bash
terraform init
```

### 3. Planeje e Aplique

```bash
terraform plan
terraform apply
```

### 4. Configure o kubectl

Após a criação do cluster, configure o acesso local:

```bash
aws eks update-kubeconfig --region <region> --name <cluster-name>
```

## Componentes dos Módulos

### Módulo VPC (`modules/vpc`)
- Criação de VPC, Subnets, Internet Gateway, NAT Gateway e Route Tables.

### Módulo EKS (`modules/eks`)
- Criação do Control Plane EKS, Node Groups gerenciados, IAM Roles e CSI Drivers (EBS, EFS).

### Módulo EFS (`modules/efs`)
- Criação de Amazon EFS File Systems com criptografia, mount targets e security groups.

### Módulo Addons (`modules/kubernetes-addons`)
- Instalação do Karpenter (com NodePools e EC2NodeClasses), AWS Load Balancer Controller e StorageClasses (EBS gp3, EFS).

## Resolução de Problemas

### Erro 403 ao localizar chart do Karpenter

Se encontrar erro `Unable to locate chart oci://public.ecr.aws/karpenter/karpenter`:

```bash
helm registry logout public.ecr.aws
```

Se o problema persistir, tente executar o comando para se logar:

```bash
aws ecr-public get-login-password --region us-east-1 | helm registry login --username AWS --password-stdin public.ecr.aws
```