# Exemplo Completo de Uso

## 1. Criar ExternalSecret no Kubernetes

```yaml
# Arquivo: k8s-manifests/external-secret.yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: minha-app-secret
  namespace: default
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets-manager
    kind: ClusterSecretStore
  target:
    name: minha-app-secret-k8s
    creationPolicy: Owner
  dataFrom:
    - extract:
        key: prod/minha-app
```

Aplicar:
```bash
kubectl apply -f k8s-manifests/external-secret.yaml
```

## 2. Usar no Deployment

```yaml
# Arquivo: k8s-manifests/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minha-app
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: minha-app
  template:
    metadata:
      labels:
        app: minha-app
    spec:
      containers:
      - name: app
        image: nginx:1.27-alpine
        envFrom:
        - secretRef:
            name: minha-app-secret-k8s
        ports:
        - containerPort: 80
```

