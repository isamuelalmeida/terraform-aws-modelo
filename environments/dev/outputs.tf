output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

output "efs_id" {
  description = "EFS file system ID for use in Kubernetes StorageClass"
  value       = module.efs.efs_id
}

output "efs_dns_name" {
  description = "EFS DNS name"
  value       = module.efs.efs_dns_name
}
