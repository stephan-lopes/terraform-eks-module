resource "aws_iam_policy" "this" {
  name        = var.policy.name
  name_prefix = var.policy.name_prefix
  description = var.policy.description
  path        = var.policy.path
  policy      = var.policy.policy

  tags = {
    ManagedBy = "terraform"
    Module    = "iam"
  }
}
