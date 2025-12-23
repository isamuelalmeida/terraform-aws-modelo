# Módulo GitHub OIDC

Módulo Terraform para configurar integração OIDC entre GitHub Actions e AWS, permitindo autenticação sem credenciais estáticas.

## Características

- ✅ Criação automática do OIDC Provider
- ✅ Suporte a múltiplos repositórios com roles dedicadas
- ✅ Configuração dinâmica de permissões (managed + inline policies)
- ✅ Validações de segurança integradas
- ✅ Suporte a diferentes branches, tags e ambientes
- ✅ Session duration configurável

## Uso Básico

```hcl
module "github_oidc" {
  source = "../../modules/github-oidc"

  env  = "dev"
  name = "myproject"

  github_repositories = {
    infra-repo = {
      subjects = [
        "repo:myorg/infra-repo:ref:refs/heads/main",
        "repo:myorg/infra-repo:ref:refs/heads/develop"
      ]
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/AdministratorAccess"
      ]
    }
  }

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

## Uso Avançado - Múltiplos Repositórios

```hcl
module "github_oidc" {
  source = "../../modules/github-oidc"

  env  = "production"
  name = "myproject"

  github_repositories = {
    # Repositório de infraestrutura - Admin completo
    infra = {
      subjects = [
        "repo:myorg/infra:ref:refs/heads/main"
      ]
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/AdministratorAccess"
      ]
      max_session_duration = 7200
    }

    # Repositório de aplicação - Deploy apenas
    app-backend = {
      subjects = [
        "repo:myorg/app-backend:*"
      ]
      managed_policy_arns = []
      inline_policy_json = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "ecr:GetAuthorizationToken",
              "ecr:BatchCheckLayerAvailability",
              "ecr:GetDownloadUrlForLayer",
              "ecr:PutImage",
              "ecr:InitiateLayerUpload",
              "ecr:UploadLayerPart",
              "ecr:CompleteLayerUpload"
            ]
            Resource = "*"
          },
          {
            Effect = "Allow"
            Action = [
              "eks:DescribeCluster"
            ]
            Resource = "arn:aws:eks:us-east-1:123456789012:cluster/prod-cluster"
          }
        ]
      })
    }

    # Repositório de testes - Read-only
    qa-tests = {
      subjects = [
        "repo:myorg/qa-tests:*"
      ]
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess"
      ]
    }
  }

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

## Uso com OIDC Provider Existente

Se você já possui um OIDC Provider do GitHub na sua conta AWS, pode reutilizá-lo importando para o Terraform:

```bash
terraform import module.github_oidc.aws_iam_openid_connect_provider.github arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com
```

## Padrões de Subject

O campo `subjects` aceita padrões do GitHub OIDC:

```hcl
# Branch específica
"repo:myorg/myrepo:ref:refs/heads/main"

# Qualquer branch
"repo:myorg/myrepo:ref:refs/heads/*"

# Tag específica
"repo:myorg/myrepo:ref:refs/tags/v1.0.0"

# Qualquer tag
"repo:myorg/myrepo:ref:refs/tags/*"

# Pull requests
"repo:myorg/myrepo:pull_request"

# Ambiente específico
"repo:myorg/myrepo:environment:production"

# Qualquer coisa do repositório
"repo:myorg/myrepo:*"
```

## Configuração no GitHub Actions

Após criar o módulo, use no workflow:

```yaml
name: Deploy

on:
  push:
    branches: [main]

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: us-east-1
      
      - name: Deploy
        run: |
          aws sts get-caller-identity
          # Seus comandos aqui
```

## Inputs

| Nome | Descrição | Tipo | Padrão | Obrigatório |
|------|-----------|------|--------|-------------|
| env | Nome do ambiente | string | - | Sim |
| name | Nome do projeto | string | - | Sim |
| github_repositories | Configuração dos repositórios | map(object) | - | Sim |
| tags | Tags para recursos | map(string) | {} | Não |

## Outputs

| Nome | Descrição |
|------|-----------|
| oidc_provider_arn | ARN do OIDC provider |
| role_arns | Map de ARNs das roles criadas |

## Segurança

⚠️ **Importante:**
- Use `AdministratorAccess` apenas para testes
- Em produção, aplique princípio do menor privilégio
- Restrinja subjects a branches/tags específicas
- Revise policies regularmente
- Use inline policies para permissões granulares

## Validações

O módulo inclui validações automáticas:
- ✅ Cada repositório tem pelo menos um subject
- ✅ Session duration entre 1h e 12h
