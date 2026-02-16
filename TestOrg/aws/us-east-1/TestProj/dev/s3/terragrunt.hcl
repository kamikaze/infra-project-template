include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path   = "${get_terragrunt_dir()}/../../../../../../_envcommon/s3.hcl"
  expose = true
}

terraform {
  source = "${include.envcommon.locals.base_source_url}?version=4.2.1"
}
