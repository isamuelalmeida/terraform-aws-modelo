variable "env" {
  description = "Environment name"
  type        = string
}

variable "name" {
  description = "Project name"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "zone1" {
  description = "Availability Zone 1"
  type        = string
}

variable "zone2" {
  description = "Availability Zone 2"
  type        = string
}

variable "eks_version" {
  description = "Kubernetes version"
  type        = string

  validation {
    condition     = can(regex("^1\\.(2[89]|3[0-9])$", var.eks_version))
    error_message = "EKS version must be between 1.28 and 1.39."
  }
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
}

variable "eks_config" {
  description = "EKS Configuration including NodePools"
  type        = any
}
