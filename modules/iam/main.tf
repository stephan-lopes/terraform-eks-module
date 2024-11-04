locals {
  policy_prefix = "terraform-iam-policy-"
  role_prefix   = "terraform-iam-role-"

  nestedlist = flatten([
    for k, v in module.role : [
      for key, s in var.roles[k].policy_arns : {
        key  = format("%s-%s-%s", key, v.this.name, s)
        name = v.this.name
        arn  = s
      }
    ]
  ])

}

module "policy" {
  for_each = { for idx, policy in var.policies : idx => policy }
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
  for_each = { for idx, role in var.roles : idx => role }
  source   = "./role"
  role = {
    name                 = try(length(each.value.name) > 0 ? each.value.name : null, null)
    name_prefix          = each.value.name == null ? local.role_prefix : null
    description          = each.value.description
    path                 = each.value.path
    max_session_duration = each.value.max_session_duration
    assume_role_policy   = jsonencode(each.value.assume_role_policy)
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = { for o in local.nestedlist : o.key => o }

  role       = each.value.name
  policy_arn = each.value.arn
}
