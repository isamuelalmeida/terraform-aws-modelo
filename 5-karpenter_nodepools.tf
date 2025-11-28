resource "kubectl_manifest" "karpenter_nodepool_default" {
  depends_on = [helm_release.karpenter]

  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      name: ${local.env}-${local.eks_name}-default
    spec:
      disruption:
        consolidateAfter: 30s
        consolidationPolicy: WhenEmpty
        expireAfter: Never
      limits:
        cpu: ${local.eks.default.nodepool.limits.cpu}
        memory: ${local.eks.default.nodepool.limits.memory}
      template:
        metadata:
          labels:
            nodeTypeClass: default
        spec:
          nodeClassRef:
            group: karpenter.k8s.aws
            kind: EC2NodeClass
            name: ${local.env}-${local.eks_name}-default
          requirements:
            - key: kubernetes.io/os
              operator: In
              values: ${jsonencode(local.eks.default.nodepool.requirements.os)}
            - key: karpenter.k8s.aws/instance-hypervisor
              operator: In
              values: ${jsonencode(local.eks.default.nodepool.requirements.instance_hypervisor)}
            - key: kubernetes.io/arch
              operator: In
              values: ${jsonencode(local.eks.default.nodepool.requirements.arch)}
            - key: karpenter.sh/capacity-type
              operator: In
              values: ${jsonencode(local.eks.default.nodepool.requirements.capacity_type)}
            - key: karpenter.k8s.aws/instance-family
              operator: In
              values: ${jsonencode(local.eks.default.nodepool.requirements.instance_family)}
            - key: karpenter.k8s.aws/instance-cpu
              operator: In
              values: ${jsonencode(local.eks.default.nodepool.requirements.instance_cpu)}
            - key: topology.kubernetes.io/zone
              operator: In
              values: ${jsonencode(local.eks.default.nodepool.requirements.zone)}
  YAML
}

resource "kubectl_manifest" "karpenter_ec2nodeclass_default" {
  depends_on = [module.karpenter, helm_release.karpenter]

  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1
    kind: EC2NodeClass
    metadata:
      name: ${local.env}-${local.eks_name}-default
    spec:
      role: ${module.eks.eks_managed_node_groups["initial"].iam_role_name}
      amiSelectorTerms:
        - alias: al2023@latest
      blockDeviceMappings:
        - deviceName: ${local.eks.default.ec2_node_class.device_name}
          ebs:
            volumeSize: ${local.eks.default.ec2_node_class.volume_size}
            volumeType: ${local.eks.default.ec2_node_class.volume_type}
            encrypted: true
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${local.env}-${local.eks_name}
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${local.env}-${local.eks_name}
      tags:
        karpenter.sh/discovery: ${local.env}-${local.eks_name}
        Name: eks-node-${local.env}-${local.eks_name}-default
        Environment: ${local.env}
  YAML
}
