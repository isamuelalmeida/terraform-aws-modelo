output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

output "karpenter_queue_name" {
  value = module.kubernetes_addons.karpenter_queue_name
}

output "eks_managed_node_groups_iam_role_name" {
  description = "EKS initial node group IAM role Name"
  value       = module.eks.eks_managed_node_groups["eks-node-initial"].iam_role_name
}

output "github_oidc_provider_arn" {
  description = "GitHub OIDC Provider ARN"
  value       = length(module.github_oidc) > 0 ? module.github_oidc[0].oidc_provider_arn : null
}

output "github_role_arns" {
  description = "GitHub IAM Role ARNs"
  value       = length(module.github_oidc) > 0 ? module.github_oidc[0].role_arns : {}
}
