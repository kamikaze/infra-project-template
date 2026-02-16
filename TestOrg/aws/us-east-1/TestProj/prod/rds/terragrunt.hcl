include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path   = "${get_terragrunt_dir()}/../../../../../../_envcommon/rds.hcl"
  expose = true
}

terraform {
  source = "${include.envcommon.locals.base_source_url}?version=6.9.0"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  vpc_id                = dependency.vpc.outputs.vpc_id
  db_subnet_group_name  = dependency.vpc.outputs.database_subnet_group_name
  vpc_security_group_ids = [dependency.vpc.outputs.default_security_group_id] # Should be more specific in reality
}
