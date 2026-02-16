include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path   = "${get_terragrunt_dir()}/../../../../../../_envcommon/vpc.hcl"
  expose = true
}

terraform {
  source = "${include.envcommon.locals.base_source_url}?version=5.13.0"
}
