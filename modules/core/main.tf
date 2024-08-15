# ===================================================================
#! Core Configuration entrypoint (VPC + EKS)
# ===================================================================

locals {
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)
  name = format("mtsaas-%s-vpc", var.env)
}