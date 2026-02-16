# Common SSM configuration

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env              = local.environment_vars.locals.environment

  # Use local module
  base_source_url = "${get_repo_root()}/modules/ssm-parameters"
}

inputs = {
  parameters = {
    "/myapp/${local.env}/DB_PASSWORD" = {
      description = "Database password for myapp"
      value       = "placeholder" # This should be overridden by environment variable TF_VAR_db_password
    }
    "/myapp/${local.env}/API_KEY" = {
      description = "API key for external service"
      value       = "placeholder" # Overridden by TF_VAR_api_key
    }
  }
}
