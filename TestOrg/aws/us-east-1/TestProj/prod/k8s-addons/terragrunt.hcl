include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path   = "${get_terragrunt_dir()}/../../../../../../_envcommon/k8s-addons.hcl"
  expose = true
}

terraform {
  source = include.envcommon.locals.base_source_url
}

dependency "eks" {
  config_path = "../eks"
}
