variable "env" {
  description = "Environment name"
  type        = string
}

variable "name" {
  description = "Project name"
  type        = string
}

variable "eks_version" {
  description = "Kubernetes version"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "instance_types" {
  description = "List of instance types for the initial node group"
  type        = list(string)
  default     = ["c6i.xlarge", "c6a.xlarge"]
}


variable "capacity_type" {
  description = "Capacity type for the initial node group (SPOT or ON_DEMAND)"
  type        = string
  default     = "SPOT"
}

variable "disk_size" {
  description = "Disk size for the initial node group"
  type        = number
  default     = 30
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the initial node group"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the initial node group"
  type        = number
  default     = 3
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in the initial node group"
  type        = number
  default     = 2
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}

variable "addon_versions" {
  description = "Versions for EKS addons"
  type = object({
    kube_proxy             = string
    vpc_cni                = string
    coredns                = string
    eks_pod_identity_agent = string
    metrics_server         = string
    aws_ebs_csi_driver     = string
    aws_efs_csi_driver     = string
  })
  default = {
    kube_proxy             = "v1.34.1-eksbuild.2"
    vpc_cni                = "v1.20.5-eksbuild.1"
    coredns                = "v1.12.4-eksbuild.1"
    eks_pod_identity_agent = "v1.3.10-eksbuild.1"
    metrics_server         = "v0.8.0-eksbuild.5"
    aws_ebs_csi_driver     = "v1.53.0-eksbuild.1"
    aws_efs_csi_driver     = "v2.1.15-eksbuild.1"
  }
}
