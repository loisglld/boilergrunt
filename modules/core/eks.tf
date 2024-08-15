# ===================================================================
#! Elastic Kubernetes Service (EKS) module entry point.
#* EKS is a managed Kubernetes service provided by AWS.
# ===================================================================

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.17.2"

  cluster_name = local.name

  cluster_version = "1.30"

  # Give the Terraform identity admin access to the cluster
  # which will allow it to deploy resources into the cluster
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access           = true

  cluster_addons = {
    coredns = {
      configuration_values = jsonencode({
        tolerations = [
          # Allow CoreDNS to run on the same nodes as the Karpenter controller
          # for use during cluster creation when Karpenter nodes do not yet exist
          {
            key    = "karpenter.sh/controller"
            value  = "true"
            effect = "NoSchedule"
          }
        ]
      })
    }
    aws-ebs-csi-driver     = { most_recent = true }
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {} # TODO: replace w/ calico
  }

  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
    # EBS CSI driver iam role
    iam_role_additional_policies = { AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy" }
  }

  eks_managed_node_groups = {
    core = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.xlarge"]

      min_size     = 1
      max_size     = 10
      desired_size = 1
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Workaround for the following error:
  # ResourceAlreadyExistsException: The specified log group already exists
  create_cloudwatch_log_group = false

  tags = merge(
    { name = "eks-${var.env}" },
    var.tags, {
      # NOTE - if creating multiple security groups with this module, only tag the
      # security group that Karpenter should utilize with the following tag
      # (i.e. - at most, only one security group should have this tag in your account)
      "karpenter.sh/discovery" = local.name
    }
  )
}

data "aws_eks_cluster_auth" "this" {
  name = local.name
}

# ===================================================================
#! Outputs
# ===================================================================

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = try(module.eks.cluster_name, "No cluster name found")
}

output "eks_cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = try(module.eks.cluster_endpoint, "No endpoint found")
}

output "eks_cluster_auth_token" {
  sensitive   = true
  description = "Authentication token for the EKS cluster"
  value       = try(data.aws_eks_cluster_auth.this.token, "No authentication token found")
}

output "eks_cluster_certificate_authority_data" {
  description = "Certificate authority data for the EKS cluster"
  value       = try(module.eks.cluster_certificate_authority_data, "No certificate authority data found")
}
