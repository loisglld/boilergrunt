# ===================================================================
#! Virtual Private Cloud (VPC) module entry point.
#* VPC is a virtual network dedicated to your AWS account.
# ===================================================================

# Interrogates AWS 
# fetch available AZs according to provider region
data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.9.0"

  name = local.name
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    # Tags subnets for Karpenter auto-discovery
    "karpenter.sh/discovery" = local.name
  }

  tags = merge(
    { name = "vpc-${var.env}" },
    var.tags
  )
}
