variable "env" {
  description = "Environment name"
  type        = string
}

variable "name" {
  description = "Project name"
  type        = string
}

variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS Cluster endpoint"
  type        = string
}

variable "eks_managed_node_groups" {
  description = "Map of managed node groups from EKS module"
  type        = any
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "nodepool_config" {
  description = "Configuration for Karpenter NodePool and EC2NodeClass"
  type = object({
    nodepool = object({
      requirements = object({
        os                  = list(string)
        instance_hypervisor = list(string)
        arch                = list(string)
        capacity_type       = list(string)
        instance_family     = list(string)
        instance_cpu        = list(string)
        zone                = list(string)
      })
      limits = object({
        cpu    = string
        memory = string
      })
    })
    ec2_node_class = object({
      device_name = string
      volume_size = string
      volume_type = string
    })
  })
}

variable "efs_storage_classes" {
  description = "Map of EFS StorageClasses to create"
  type = map(object({
    efs_id           = string
    provisioning_mode = optional(string, "efs-ap")
    directory_perms  = optional(string, "700")
  }))
  default = {}
}
