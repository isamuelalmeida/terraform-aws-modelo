locals {
  env = "staging"
  region = "us-east-2"
  zone1 = "us-east-2a" 
  zone2 = "us-east-2b"
  eks_name = "demo"
  eks_version = "1.34"

  eks = {
      default = {
          nodepool = {
            requirements = {
              os                  = ["linux"]
              instance_hypervisor = ["nitro"]
              arch                = ["amd64"]
              capacity_type       = ["spot"]
              instance_family     = ["t3", "t3a"]
              instance_cpu        = ["2", "4", "8", "16"]
              zone                = ["us-east-2a"]
            }
            limits = {
              cpu    = "100"
              memory = "256Gi"
            }
          }
          ec2_node_class = {
            device_name = "/dev/xvda"
            volume_size = "30Gi"
            volume_type = "gp3"
          }
      }
  }
}