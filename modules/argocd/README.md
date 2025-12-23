# Módulo ArgoCD

Instala o ArgoCD via Helm no cluster EKS.

## Recursos Criados

- Namespace `argocd`
- Helm Release do ArgoCD

## Inputs

| Nome | Descrição | Tipo | Padrão | Obrigatório |
|------|-----------|------|--------|-------------|
| chart_version | Versão do Helm chart do ArgoCD | string | "9.1.5" | Não |

## Outputs

Nenhum output é exposto. O ArgoCD é gerenciado de forma independente.

## Uso

### Uso Básico (versão padrão)

```hcl
module "argocd" {
  source = "../../modules/argocd"
}
```

### Uso com Versão Customizada

```hcl
module "argocd" {
  source = "../../modules/argocd"
  
  chart_version = "9.2.0"
}
```

## Acesso ao ArgoCD

### Obter senha inicial do admin

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Port-forward para acessar a UI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Acesse: https://localhost:8080
- Usuário: `admin`
- Senha: (obtida no comando acima)
