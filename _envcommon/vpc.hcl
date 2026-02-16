# Common VPC configuration

locals {
  # Load environment variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env              = local.environment_vars.locals.environment

  # Expose the base source URL so different versions of the module can be used in different environments
  base_source_url = "tfr:///terraform-aws-modules/vpc/aws"
}

inputs = {
  name = "vpc-${local.env}"
  cidr = local.env == "prod" ? "10.1.0.0/16" : "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = local.env == "prod" ? ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"] : ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = local.env == "prod" ? ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"] : ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true # Save cost for dev/test

  enable_ipv6                                    = true
  assign_generated_ipv6_cidr_block                = true
  private_subnet_assign_ipv6_address_on_creation = true
  public_subnet_assign_ipv6_address_on_creation  = true

  # Tag subnets for EKS
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}
