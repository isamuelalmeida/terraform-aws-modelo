# Módulo Kubernetes Addons

Módulo para instalação de addons e configurações do Kubernetes no cluster EKS.

## Recursos Criados

- **Karpenter**: Autoscaler de nodes com NodePool e EC2NodeClass
- **AWS Load Balancer Controller**: Gerenciamento de ALB/NLB
- **StorageClasses**: gp3 (EBS) e EFS (configurável)

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

O Karpenter é configurado com:
- **NodePool**: Define requisitos e limites de recursos
- **EC2NodeClass**: Configura AMI, volumes e networking
- **Consolidation**: Habilitado para otimização de custos

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

Instalado via Helm chart oficial da AWS. Permite criar:
- Application Load Balancers (ALB) via Ingress
- Network Load Balancers (NLB) via Service

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
