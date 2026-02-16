# Common S3 configuration

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  org_vars         = read_terragrunt_config(find_in_parent_folders("org.hcl"))
  project_vars     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  
  env     = local.environment_vars.locals.environment
  org     = local.org_vars.locals.org_name
  project = local.project_vars.locals.project_name

  base_source_url = "tfr:///terraform-aws-modules/s3-bucket/aws"
}

inputs = {
  bucket = lower("${local.org}-${local.project}-${local.env}-data")

  acl           = "private"
  force_destroy = local.env == "prod" ? false : true

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}
