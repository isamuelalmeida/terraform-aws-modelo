# EXEMPLO: Descomente para criar um secret de exemplo no Secrets Manager
# e um ExternalSecret para sincronizá-lo com o Kubernetes

# resource "aws_secretsmanager_secret" "example_app" {
#   name                    = "${var.env}/example-app"
#   description             = "Example app secrets"
#   recovery_window_in_days = 0
# 
#   tags = var.tags
# }
# 
# resource "aws_secretsmanager_secret_version" "example_app" {
#   secret_id = aws_secretsmanager_secret.example_app.id
# 
#   secret_string = jsonencode({
#     DB_HOST     = "db.example.internal"
#     DB_USER     = "app_user"
#     DB_PASSWORD = "change-me-in-production"
#     API_KEY     = "example-api-key"
#   })
# }
# 
# resource "kubectl_manifest" "external_secret_example" {
#   depends_on = [kubectl_manifest.secretstore_aws]
# 
#   yaml_body = <<-YAML
#     apiVersion: external-secrets.io/v1beta1
#     kind: ExternalSecret
#     metadata:
#       name: example-app-secret
#       namespace: default
#     spec:
#       refreshInterval: 1h
#       secretStoreRef:
#         name: aws-secrets-manager
#         kind: ClusterSecretStore
#       target:
#         name: example-app-secret-k8s
#         creationPolicy: Owner
#       dataFrom:
#         - extract:
#             key: ${aws_secretsmanager_secret.example_app.name}
#   YAML
# }
