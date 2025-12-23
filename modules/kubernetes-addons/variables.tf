variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "eks_managed_node_groups" {
  description = "Map of managed node groups from EKS module"
  type        = any
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
