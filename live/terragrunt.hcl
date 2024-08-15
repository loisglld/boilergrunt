# ===================================================================
#! Root locals 
#
#* The `local` block is used to load variables from the account / 
#* region / env-level configuration files. These variables are 
#* loaded following the hierarchy defined by where the 
#* `terragrunt apply` command is run.

#* Example:
#* ```shell
#* cd live/non-prod/eu-west-1/dev/karpenter
#* terragrunt apply
#* ```
#* In this case, the HCL files loaded will be:
#* - live/non-prod/account.hcl
#* - live/non-prod/eu-west-1/region.hcl
#* - live/non-prod/eu-west-1/dev/env.hcl
# ===================================================================
locals {
  # Automatically load account / region / env-level variables
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract and create variables we need for easy access
  tags = {
    terraform = "true"
    env       = local.environment_vars.locals.env
  }
}

remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "mtsaas-tf-backend"
    key            = "${path_relative_to_include()}/tf.tfstate"
    region         = "${local.region_vars.locals.aws_region}"
    profile        = "${local.account_vars.locals.aws_profile}"
    dynamodb_table = "mtsaas-tf-locks"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region  = "${local.region_vars.locals.aws_region}"
  profile = "${local.account_vars.locals.aws_profile}"
}
EOF
}

# ===================================================================
#! Inputs 
#
#* The `inputs` block is used to pass variables to the TF config.
#* These variables are merged, so you can benefit from the DRY
#* principle and avoid repeating the same values that are common
#* across multiple configuration levels :
#* root -> account -> region -> environment -> grunt module
# ===================================================================

inputs = merge(
  local.account_vars.locals,     // overriden by region_vars
  local.region_vars.locals,      // overriden by environment_vars
  local.environment_vars.locals, // overriden by module-specific vars (defined inside the grunt module's terragrunt.hcl)
  {
    tags = local.tags
  }
)
