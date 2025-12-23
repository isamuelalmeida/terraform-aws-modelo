variable "env" {
  description = "Environment name"
  type        = string
}

variable "name" {
  description = "Project name"
  type        = string
}

variable "github_repositories" {
  description = <<-EOT
    Map of GitHub repositories and their IAM role configurations.
    Key: Friendly name for the repository/role
    Value: Object with:
      - subjects: List of GitHub OIDC subject patterns (e.g., "repo:org/repo:ref:refs/heads/main")
      - managed_policy_arns: List of AWS managed policy ARNs to attach
      - inline_policy_json: Optional inline policy JSON string
      - max_session_duration: Session duration in seconds (default: 3600)
  EOT
  type = map(object({
    subjects             = list(string)
    managed_policy_arns  = list(string)
    inline_policy_json   = optional(string)
    max_session_duration = optional(number, 3600)
  }))



  validation {
    condition = alltrue([
      for repo in var.github_repositories :
      length(repo.subjects) > 0
    ])
    error_message = "Each repository must have at least one subject pattern."
  }

  validation {
    condition = alltrue([
      for repo in var.github_repositories :
      repo.max_session_duration >= 3600 && repo.max_session_duration <= 43200
    ])
    error_message = "max_session_duration must be between 3600 (1 hour) and 43200 (12 hours)."
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
