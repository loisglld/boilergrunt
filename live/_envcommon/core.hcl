# ===================================================================
#! Grunt Module Configuration 
#
#* This file points to the TF module source code and sets the input
#* variables for the module. You can use this file to setup common
#* variables accros all `core` modules in the entire grunt config.
# ===================================================================

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env = local.environment_vars.locals.env
  base_source_url = "${dirname(find_in_parent_folders())}/../modules/core"
}

# ===================================================================
#! Module Inputs 
#
#* This `inputs` block is used to pass variables to the TF config.
#* These variables are at the last level of the configuration 
#* hierarchy. So, they will override any other variables defined
#* at the upper levels.
# ===================================================================

inputs = {
  vpc_cidr = "12.0.0.0/16"
}
