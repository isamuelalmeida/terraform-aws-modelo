output "karpenter_queue_name" {
  description = "Karpenter SQS queue name"
  value       = module.karpenter.queue_name
}

output "karpenter_service_account_role_arn" {
  description = "Karpenter service account IAM role ARN"
  value       = module.karpenter.iam_role_arn
}