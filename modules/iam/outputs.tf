output "cluster_role_arn" {
  value = flatten([
    for role_index, role_item in module.role : role_item.role_arn if var.roles[role_index].assign_as_cluster_role
  ])
}

output "node_group_role_arn" {
  value = flatten([
    for role_index, role_item in module.role : role_item.role_arn if !var.roles[role_index].assign_as_cluster_role
  ])
}
