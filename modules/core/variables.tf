# ===================================================================
#! Required Variables
# ===================================================================

variable "env" {
  description = "The environment in which the resources are created (e.g. dev, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC (e.g. 10.0.0.0/16)"
  type        = string
}

# ===================================================================
#! Optional Variables
# ===================================================================

variable "tags" {
  description = "A map of tags to add to all resources (e.g. { terraform = true })"
  type        = map(string)
  default     = { terraform = "true" }
}