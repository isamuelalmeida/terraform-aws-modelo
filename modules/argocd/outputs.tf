output "release_name" {
  value       = helm_release.argocd.name
  description = "ArgoCD Helm release name"
}
