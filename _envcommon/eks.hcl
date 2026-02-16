# Common EKS configuration

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env              = local.environment_vars.locals.environment

  base_source_url = "tfr:///terraform-aws-modules/eks/aws"
}

inputs = {
  cluster_name    = "eks-${local.env}"
  cluster_version = "1.31"

  cluster_endpoint_public_access = true

  # Cilium requirements:
  # 1. Disable VPC CNI
  # 2. Add proper tags
  # 3. Node group needs to be configured for Cilium
  
  # We'll use a single tiny node group
  eks_managed_node_groups = {
    main = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.small"]
      capacity_type  = "SPOT" # Save cost
    }
  }

  # Enable OIDC Provider for IRSA
  enable_irsa = true

  # To install Cilium, we often want to manage it via Helm after cluster is up.
  # For this template, we prepare the cluster for it.
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    # vpc-cni is explicitly omitted to allow Cilium installation
  }
}
