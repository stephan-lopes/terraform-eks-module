
output "public_subnets_ids" {
  value = [for subnet in aws_subnet.this : subnet.id if subnet.tags.Network == "Public"]
}

output "private_subnets_ids" {
  value = [for subnet in aws_subnet.this : subnet.id if subnet.tags.Network == "Private"]
}

output "security_groups_ids" {
  value = flatten([
    for sg in aws_security_group.this : sg.id
  ])
}
