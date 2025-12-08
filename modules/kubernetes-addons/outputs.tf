output "karpenter_service_account" {
  description = "Service Account used by Karpenter"
  value       = module.karpenter.service_account
}

output "karpenter_queue_name" {
  value = module.karpenter.queue_name
}

output "karpenter_service_account_role_arn" {
  value = module.karpenter.iam_role_arn
}