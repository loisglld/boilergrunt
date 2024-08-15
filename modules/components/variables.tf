# ===================================================================
#! Required Variables
# ===================================================================

variable "env" {
  description = "The environment in which the resources are created (e.g. dev, prod)"
  type        = string
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "eks_cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  type        = string
}

variable "eks_cluster_certificate_authority_data" {
  description = "Certificate authority data for the EKS cluster"
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