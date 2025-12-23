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

variable "secrets_arns" {
  description = "List of Secrets Manager ARNs that ESO can access. Use specific ARNs in production."
  type        = list(string)
  default     = ["*"]

  validation {
    condition     = length(var.secrets_arns) > 0
    error_message = "At least one secret ARN must be specified."
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
