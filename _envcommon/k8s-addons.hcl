# Common K8s addons configuration

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env              = local.environment_vars.locals.environment

  base_source_url = "${get_repo_root()}/modules/k8s-addons"
}

inputs = {
  # Add any specific inputs for the addons module
}
