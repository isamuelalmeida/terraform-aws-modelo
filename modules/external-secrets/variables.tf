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
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "secrets_arns" {
  description = "List of Secrets Manager ARNs that ESO can access"
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
