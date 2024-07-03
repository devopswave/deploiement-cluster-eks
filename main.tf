# Fournisseur AWS
provider "aws" {
  region = var.region
}

# Filtrer les zones de disponibilité locales qui ne sont pas 
# actuellement prises en charge par les groupes de nœuds managés
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Définir des variables locales
locals {
  cluster_name = "${var.project_name}-eks-${random_string.suffix.result}"
}

# Générer une chaîne aléatoire pour le suffixe du nom de cluster
resource "random_string" "suffix" {
  length  = 8
  special = false
}

# Module VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "${var.project_name}-vpc"

  cidr = var.vpc_cidr
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = var.cidrs_private
  public_subnets  = var.cidrs_public

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

# Module EKS
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = local.cluster_name
  cluster_version = "1.30"

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  # cluster_addons = {
  #   aws-ebs-csi-driver = {
  #     service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
  #   }
  # }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    ami_type = var.node_group_type
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = [var.node_instance_type]

      min_size     = var.scaling_config.min_size
      max_size     = var.scaling_config.max_size
      desired_size = var.scaling_config.desired_size
    }

    two = {
      name = "node-group-2"

      instance_types = [var.node_instance_type]

      min_size     = var.scaling_config.min_size
      max_size     = var.scaling_config.max_size
      desired_size = var.scaling_config.desired_size
    }
  }
}

# Vous pouvez activer le pilote CSI EBS pour EKS en suivant les instructions :
# https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/
# data "aws_iam_policy" "ebs_csi_policy" {
#   arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
# }

# Module IRSA pour le pilote CSI EBS
# module "irsa-ebs-csi" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
#   version = "5.39.0"

#   create_role                   = true
#   role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
#   provider_url                  = module.eks.oidc_provider
#   role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
#   oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
# }
