# Root terragrunt.hcl

locals {
  # Load account, region and environment variables
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  org_vars         = read_terragrunt_config(find_in_parent_folders("org.hcl"))
  project_vars     = read_terragrunt_config(find_in_parent_folders("project.hcl"))

  # Extract variables for easy access
  account_name = local.account_vars.locals.account_name
  account_id   = local.account_vars.locals.aws_account_id
  aws_region   = local.region_vars.locals.aws_region
  env          = local.environment_vars.locals.environment
  org          = local.org_vars.locals.org_name
  project      = local.project_vars.locals.project_name
}

# Generate AWS provider
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  allowed_account_ids = ["${local.account_id}"]

  default_tags {
    tags = {
      Organization = "${local.org}"
      Project      = "${local.project}"
      Environment  = "${local.env}"
      ManagedBy    = "Terragrunt"
    }
  }
}

# These are needed for EKS/K8s related modules
data "aws_eks_cluster" "cluster" {
  count = length(regexall("k8s-addons", get_terragrunt_dir())) > 0 ? 1 : 0
  name  = "eks-${local.env}"
}

data "aws_eks_cluster_auth" "cluster" {
  count = length(regexall("k8s-addons", get_terragrunt_dir())) > 0 ? 1 : 0
  name  = "eks-${local.env}"
}

provider "kubernetes" {
  host                   = length(data.aws_eks_cluster.cluster) > 0 ? data.aws_eks_cluster.cluster[0].endpoint : ""
  cluster_ca_certificate = length(data.aws_eks_cluster.cluster) > 0 ? base64decode(data.aws_eks_cluster.cluster[0].certificate_authority[0].data) : ""
  token                  = length(data.aws_eks_cluster_auth.cluster) > 0 ? data.aws_eks_cluster_auth.cluster[0].token : ""
}

provider "helm" {
  kubernetes {
    host                   = length(data.aws_eks_cluster.cluster) > 0 ? data.aws_eks_cluster.cluster[0].endpoint : ""
    cluster_ca_certificate = length(data.aws_eks_cluster.cluster) > 0 ? base64decode(data.aws_eks_cluster.cluster[0].certificate_authority[0].data) : ""
    token                  = length(data.aws_eks_cluster_auth.cluster) > 0 ? data.aws_eks_cluster_auth.cluster[0].token : ""
  }
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt = true
    bucket  = "tf-state-${local.org}-${local.project}-${local.account_id}-${local.aws_region}"
    key     = "${path_relative_to_include()}/terraform.tfstate"
    region  = local.aws_region
    # S3 Native locking (no DynamoDB) - requires Terraform 1.10+
    # Note: Terragrunt also needs to be configured to handle this if it's not transparent.
    # Actually, as of recent versions, just setting use_lockfile = true in the s3 backend config works.
    use_lockfile = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Combine all variables in a single object for convenience
inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  local.environment_vars.locals,
  local.org_vars.locals,
  local.project_vars.locals,
)
