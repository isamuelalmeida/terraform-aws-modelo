resource "kubernetes_storage_class" "gp3" {
  depends_on = [helm_release.karpenter]

  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type      = "gp3"
    encrypted = "true"
    fsType    = "ext4"
  }
}

resource "kubernetes_storage_class" "efs" {
  for_each = var.efs_storage_classes

  depends_on = [helm_release.karpenter]

  metadata {
    name = each.key
  }

  storage_provisioner = "efs.csi.aws.com"
  reclaim_policy      = "Delete"

  parameters = {
    provisioningMode = each.value.provisioning_mode
    fileSystemId     = each.value.efs_id
    directoryPerms   = each.value.directory_perms
  }
}
