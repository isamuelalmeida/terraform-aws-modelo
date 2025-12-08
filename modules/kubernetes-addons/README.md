# Módulo Kubernetes Addons

Módulo para criação de recursos AWS (IAM Roles, Policies, Pod Identity) necessários para addons Kubernetes no cluster EKS.

## Recursos Criados

- **Karpenter**: IAM Role, Instance Profile e Pod Identity Association
- **AWS Load Balancer Controller**: IAM Role, Policy e Pod Identity Association
- **StorageClasses**: gp3 (EBS) e EFS (configurável)

**Nota:** Os Helm charts do Karpenter e AWS Load Balancer Controller devem ser gerenciados pelo ArgoCD.

## Inputs

| Nome | Descrição | Tipo | Obrigatório |
|------|-----------|------|-------------|
| env | Nome do ambiente | string | Sim |
| name | Nome do projeto | string | Sim |
| cluster_name | Nome do cluster EKS | string | Sim |
| cluster_endpoint | Endpoint do cluster EKS | string | Sim |
| eks_managed_node_groups | Node groups do EKS | any | Sim |
| vpc_id | ID da VPC | string | Sim |
| nodepool_config | Configuração do Karpenter NodePool | object | Sim |
| efs_storage_classes | Map de StorageClasses EFS | map(object) | Não |

## Outputs

| Nome | Descrição |
|------|-----------|
| karpenter_node_role_arn | ARN da IAM Role dos nodes Karpenter |
| karpenter_node_instance_profile_name | Nome do Instance Profile |

## StorageClasses

### EBS gp3 (Padrão)

Criado automaticamente como StorageClass padrão do cluster:

```yaml
name: gp3
provisioner: ebs.csi.aws.com
type: gp3
encrypted: true
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
```

### EFS (Configurável)

Criado dinamicamente baseado no input `efs_storage_classes`:

```hcl
efs_storage_classes = {
  efs = {
    efs_id            = "fs-xxxxx"
    provisioning_mode = "efs-ap"      # opcional, padrão: "efs-ap"
    directory_perms   = "700"         # opcional, padrão: "700"
  }
}
```

## Exemplo de Uso

### Configuração Básica

```hcl
module "kubernetes_addons" {
  source = "../../modules/kubernetes-addons"

  env                     = "dev"
  name                    = "demo"
  cluster_name            = module.eks.cluster_name
  cluster_endpoint        = module.eks.cluster_endpoint
  eks_managed_node_groups = module.eks.eks_managed_node_groups
  vpc_id                  = module.vpc.vpc_id
  
  nodepool_config = {
    nodepool = {
      requirements = {
        os                  = ["linux"]
        instance_hypervisor = ["nitro"]
        arch                = ["amd64"]
        capacity_type       = ["spot"]
        instance_family     = ["t3", "t3a"]
        instance_cpu        = ["2", "4"]
        zone                = ["us-east-1a", "us-east-1b"]
      }
      limits = {
        cpu    = "100"
        memory = "200Gi"
      }
    }
    ec2_node_class = {
      device_name = "/dev/xvda"
      volume_size = "30Gi"
      volume_type = "gp3"
    }
  }

  efs_storage_classes = {
    efs = {
      efs_id = module.efs.efs_id
    }
  }
}
```

### Múltiplos StorageClasses EFS

```hcl
module "kubernetes_addons" {
  source = "../../modules/kubernetes-addons"
  # ... outras configurações

  efs_storage_classes = {
    efs = {
      efs_id = module.efs_general.efs_id
    }
    efs-logs = {
      efs_id          = module.efs_logs.efs_id
      directory_perms = "755"
    }
    efs-backups = {
      efs_id            = module.efs_backups.efs_id
      provisioning_mode = "efs-ap"
      directory_perms   = "700"
    }
  }
}
```

## Karpenter

Este módulo cria os recursos AWS necessários para o Karpenter:
- IAM Role para os nodes
- Instance Profile
- Pod Identity Association para o controller

O Helm chart do Karpenter e os recursos Kubernetes (NodePool, EC2NodeClass) devem ser gerenciados pelo ArgoCD.

### Exemplo de NodePool Config

```hcl
nodepool_config = {
  nodepool = {
    requirements = {
      os                  = ["linux"]
      instance_hypervisor = ["nitro"]
      arch                = ["amd64"]
      capacity_type       = ["spot", "on-demand"]
      instance_family     = ["t3", "t3a", "c5", "c5a"]
      instance_cpu        = ["2", "4", "8"]
      zone                = ["us-east-1a", "us-east-1b", "us-east-1c"]
    }
    limits = {
      cpu    = "1000"
      memory = "2000Gi"
    }
  }
  ec2_node_class = {
    device_name = "/dev/xvda"
    volume_size = "50Gi"
    volume_type = "gp3"
  }
}
```

## AWS Load Balancer Controller

Este módulo cria os recursos AWS necessários para o AWS Load Balancer Controller:
- IAM Role com policy oficial da AWS
- Pod Identity Association

O Helm chart do AWS Load Balancer Controller deve ser gerenciado pelo ArgoCD.

## Outputs Importantes

Os outputs deste módulo devem ser utilizados na configuração dos Helm charts via ArgoCD:

- `karpenter_node_role_arn`: ARN da IAM Role para os nodes Karpenter
- `karpenter_node_instance_profile_name`: Nome do Instance Profile para EC2NodeClass

## Uso no Kubernetes

### PVC com EBS (gp3)

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: gp3
  resources:
    requests:
      storage: 10Gi
```

### PVC com EFS

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-efs-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: efs
  resources:
    requests:
      storage: 5Gi
```
