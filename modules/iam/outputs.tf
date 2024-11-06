output "cluster_role_arn" {
  value = flatten([
    for idx, role in module.role : role.role_arn if var.roles[idx].cluster_role
  ])
}

output "node_group_role_arn" {
  value = flatten([
    for idx, role in module.role : role.role_arn if !var.roles[idx].cluster_role
  ])
}
