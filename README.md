## Estrutura do Projeto

```
.
├── modules/                  # Módulos Reutilizáveis
│   ├── vpc/                  # Lógica de Rede
│   ├── eks/                  # Lógica do Cluster EKS
│   ├── efs/                  # Amazon EFS File Systems
│   ├── kubernetes-addons/    # IAM Roles para Karpenter e LBC
│   ├── external-secrets/     # IAM Roles para External Secrets
│   └── argocd/               # Instalação do ArgoCD
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

### Módulo Kubernetes Addons (`modules/kubernetes-addons`)
- Criação de IAM Roles e Policies para Karpenter.
- Criação de IAM Roles e Policies para AWS Load Balancer Controller.
- Configuração de Pod Identity Associations.
- StorageClasses (EBS gp3, EFS).

**Nota:** Os Helm charts do Karpenter e AWS Load Balancer Controller são gerenciados pelo ArgoCD.

### Módulo External Secrets (`modules/external-secrets`)
- Criação de IAM Role e Policy para acesso ao AWS Secrets Manager.
- Configuração de Pod Identity Association.
- Criação de Namespace e ServiceAccount.

**Nota:** O Helm chart do External Secrets Operator é gerenciado pelo ArgoCD.

### Módulo ArgoCD (`modules/argocd`)
- Instalação do ArgoCD via Helm.
- Gerenciamento de aplicações Kubernetes (Karpenter, LBC, External Secrets, etc).