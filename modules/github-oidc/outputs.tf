output "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "role_arns" {
  description = "Map of repository names to their IAM role ARNs"
  value = {
    for key, role in aws_iam_role.github :
    key => role.arn
  }
}
