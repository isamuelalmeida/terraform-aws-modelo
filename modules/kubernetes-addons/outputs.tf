output "karpenter_queue_name" {
  description = "Karpenter SQS queue name"
  value       = module.karpenter.queue_name
}
