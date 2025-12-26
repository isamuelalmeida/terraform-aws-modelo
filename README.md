## Estrutura do Projeto

```
.
├── modules/                  # Módulos Reutilizáveis
│   ├── vpc/                  # Lógica de Rede
│   ├── eks/                  # Lógica do Cluster EKS
│   ├── efs/                  # Amazon EFS File Systems
│   ├── kubernetes-addons/    # IAM Roles para Karpenter e LBC
│   ├── external-secrets/     # IAM Roles para External Secrets
│   ├── github-oidc/          # OIDC Provider para GitHub Actions
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

### 5. Acesse o ArgoCD

Obtenha a senha inicial do admin:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Faça port-forward para acessar:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Acesse: https://localhost:8080
- Usuário: `admin`
- Senha: (obtida no comando acima)


### 6. Faça o deploy das aplicações e ferramentas via ArgoCD

```bash
git clone https://github.com/org-sam/infra-gitops.git
```

```bash
kubectl apply -f infra-gitops/root-app/app.yaml
```

### 7. Acesse a aplicação Frontend do E-commerce

Faça port-forward para acessar:

```bash
kubectl port-forward svc/ecommerce-frontend -n ecommerce-frontend 8081:80
```

Acesse: http://localhost:8081

### 7. Acesse o Grafana

Faça port-forward para acessar:

```bash
kubectl port-forward svc/monitoring-base-dev-demo-grafana -n monitoring 8082:80
```

Acesse: http://localhost:8082

### 8. Resolução de problemas

- Para garantir que as aplicações estejam configurado com o init-container do auto-instrumentation do opentelemetry, reinicie o deployment.

```bash
kubectl rollout restart deployment -n ecommerce-frontend ecommerce-frontend
kubectl rollout restart deployment -n ecommerce-catalog-service ecommerce-catalog-service
```

- Caso alguma aplicação no ArgoCD esteja com status OutOfSync ou Degraded, faça o sync via UI do ArgoCD, e se persistir, faça o "delete" via UI do ArgoCD da aplicação e aguarde a aplicação ser criada novamente com status de "Healthy".

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

### Módulo GitHub OIDC (`modules/github-oidc`)
- Criação de OIDC Provider para autenticação do GitHub Actions.
- Criação de IAM Role com trust policy para repositórios GitHub específicos.

### Módulo ArgoCD (`modules/argocd`)
- Instalação do ArgoCD via Helm.
- Gerenciamento de aplicações Kubernetes (Karpenter, LBC, External Secrets, etc).