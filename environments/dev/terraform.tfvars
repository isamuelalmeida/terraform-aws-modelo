env    = "dev"
name   = "demo"
region = "us-east-2"
zone1  = "us-east-2a"
zone2  = "us-east-2b"

eks_version = "1.34"
vpc_cidr    = "10.200.0.0/16"

private_subnets = ["10.200.0.0/19", "10.200.32.0/19"]
public_subnets  = ["10.200.64.0/19", "10.200.96.0/19"]

eks_config = {
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
