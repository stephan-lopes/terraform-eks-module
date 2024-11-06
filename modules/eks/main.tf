locals {
  upgrade_policy_support_types = ["EXTENDED", "STANDARD"]

  tags = {
    ManagedBy = "terraform"
    Module    = "eks"
  }
}
resource "aws_eks_cluster" "this" {
  name     = var.template.name
  role_arn = var.template.role_arn
  version  = var.template.version
  vpc_config {
    subnet_ids             = var.template.vpc_config.subnet_ids
    endpoint_public_access = var.template.vpc_config.endpoint_public_access
    public_access_cidrs    = var.template.vpc_config.public_access_cidrs
    security_group_ids     = var.template.vpc_config.control_plane_security_group_ids
  }

  access_config {
    authentication_mode = upper(var.template.access_config.authentication_mode)
  }

  upgrade_policy {
    support_type = var.template.upgrade_policy.extended ? local.upgrade_policy_support_types[0] : local.upgrade_policy_support_types[0]
  }

  tags = {
    Name      = var.template.name
    ManagedBy = local.tags.ManagedBy
    Module    = local.tags.Module
  }
}

module "irsa" {
  count  = var.template.irsa.enable ? 1 : 0
  source = "./irsa"

  eks_oidc_issuer = aws_eks_cluster.this.identity[0].oidc[0].issuer
  irsa_role_name  = var.template.irsa.role_name
}

resource "aws_eks_node_group" "this" {
  for_each = { for idx, node_group in var.template.node_groups : idx => node_group }

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.value.name
  node_role_arn   = each.value.role_arn
  subnet_ids      = each.value.subnet_ids

  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    max_size     = each.value.scaling_config.max_size
    min_size     = each.value.scaling_config.min_size
  }

  update_config {
    max_unavailable = each.value.update_config.max_unavailable
  }
}

resource "aws_eks_access_entry" "this" {

  for_each = { for idx, access_entry in var.template.access_entries : idx => access_entry }

  cluster_name      = aws_eks_cluster.this.name
  principal_arn     = each.value.principal_arn
  type              = each.value.type
  user_name         = each.value.user_name
  kubernetes_groups = each.value.kubernetes_groups
}
