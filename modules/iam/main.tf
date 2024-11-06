locals {
  policy_prefix = "terraform-iam-policy-"
  role_prefix   = "terraform-iam-role-"

  flattened_role_policies = flatten([
    for role_index, role_item in module.role : [
      for policy_arn in var.roles[role_index].attached_policy_arns : {
        identifier = format("%s-%s-%s", role_index, role_item.this.name, policy_arn)
        role_name  = role_item.this.name
        policy_arn = policy_arn
      }
    ]
  ])

}

module "policy" {
  for_each = { for policy_index, policy_item in var.policies : policy_index => policy_item }
  source   = "./policy"
  policy = {
    name        = try(length(each.value.name) > 0 ? each.value.name : null, null)
    name_prefix = each.value.name == null ? local.policy_prefix : null
    description = each.value.description
    path        = each.value.path
    policy      = jsonencode(each.value.policy)
  }
}

module "role" {
  for_each = { for role_index, role_item in var.roles : role_index => role_item }
  source   = "./role"
  role = {
    name                 = try(length(each.value.role_name) > 0 ? each.value.role_name : null, null)
    name_prefix          = each.value.role_name == null ? local.role_prefix : null
    description          = each.value.role_description
    path                 = each.value.role_path
    max_session_duration = each.value.session_duration_limit
    assume_role_policy   = jsonencode(each.value.assume_role_policy)
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = { for policy_mapping in local.flattened_role_policies : policy_mapping.identifier => policy_mapping }

  role       = each.value.role_name
  policy_arn = each.value.policy_arn
}
