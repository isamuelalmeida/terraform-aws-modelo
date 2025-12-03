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

variable "aws_region" {
  description = "AWS Region for Secrets Manager"
  type        = string
}

variable "secrets_arns" {
  description = "List of Secrets Manager ARNs that ESO can access. Use specific ARNs in production."
  type        = list(string)
  default     = ["*"]

  validation {
    condition     = length(var.secrets_arns) > 0
    error_message = "At least one secret ARN must be specified."
  }
}

variable "chart_version" {
  description = "External Secrets Operator Helm chart version"
  type        = string
  default     = "1.1.0"
}

variable "create_cluster_secret_store" {
  description = "Whether to create the ClusterSecretStore for AWS Secrets Manager"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
