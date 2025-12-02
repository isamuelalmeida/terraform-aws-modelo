output "efs_id" {
  description = "ID of the EFS file system"
  value       = module.efs.id
}

output "efs_arn" {
  description = "ARN of the EFS file system"
  value       = module.efs.arn
}

output "efs_dns_name" {
  description = "DNS name of the EFS file system"
  value       = module.efs.dns_name
}

output "security_group_id" {
  description = "Security group ID for EFS"
  value       = module.efs.security_group_id
}
