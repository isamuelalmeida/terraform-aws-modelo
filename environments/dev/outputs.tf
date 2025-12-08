output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

output "karpenter_queue_name" {
  value = module.kubernetes_addons.karpenter_queue_name
}

output "karpenter_service_account_role_arn" {
  value = module.kubernetes_addons.karpenter_service_account_role_arn
}

output "eks_managed_node_groups" {
  value = module.eks.eks_managed_node_groups
}