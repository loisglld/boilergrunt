# ===================================================================
#! Includes (HCL)
# ===================================================================

include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/core.hcl"
  expose = true
}

# ===================================================================
#! Source & Dependencies
# ===================================================================

terraform {
  source = "${include.envcommon.locals.base_source_url}"
}

inputs = {
  vpc_cidr = "13.0.0.0/16"
}