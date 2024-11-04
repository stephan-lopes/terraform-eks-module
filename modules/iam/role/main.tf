resource "aws_iam_role" "this" {
  name                 = var.role.name
  name_prefix          = var.role.name_prefix
  description          = var.role.description
  path                 = var.role.path
  max_session_duration = var.role.max_session_duration

  assume_role_policy = var.role.assume_role_policy

  tags = {
    ManagedBy = "terraform"
    Module    = "iam"
  }

  force_detach_policies = true
}
