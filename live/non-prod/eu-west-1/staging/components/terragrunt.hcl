# ===================================================================
#! Includes (HCL)
# ===================================================================

include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/components.hcl"
  expose = true
}

# ===================================================================
#! Source & Dependencies
# ===================================================================

terraform {
  source = "${include.envcommon.locals.base_source_url}"
}

dependency "core" {
  config_path = "../core"

  mock_outputs = {
    eks_cluster_name                       = "my-cluster"
    eks_cluster_endpoint                   = "https://my-cluster.eks.amazonaws.com"
    eks_cluster_certificate_authority_data = "aGVsbG8gd29ybGQ="
  }
}

inputs = {
  eks_cluster_name                       = dependency.core.outputs.eks_cluster_name
  eks_cluster_endpoint                   = dependency.core.outputs.eks_cluster_endpoint
  eks_cluster_certificate_authority_data = dependency.core.outputs.eks_cluster_certificate_authority_data
}
