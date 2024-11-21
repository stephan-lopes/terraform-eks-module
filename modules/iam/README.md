<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.74.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.74.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_policy"></a> [policy](#module\_policy) | ./policy | n/a |
| <a name="module_role"></a> [role](#module\_role) | ./role | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_policies"></a> [policies](#input\_policies) | n/a | <pre>list(object({<br/>    name        = optional(string)<br/>    description = optional(string)<br/>    path        = optional(string)<br/>    roles       = optional(string)<br/>    policy = object({<br/>      Version = string<br/>      Statement = list(object({<br/>        Action   = list(string)<br/>        Effect   = string<br/>        Resource = string<br/>      }))<br/>    })<br/>  }))</pre> | `[]` | no |
| <a name="input_roles"></a> [roles](#input\_roles) | n/a | <pre>list(object({<br/>    role_name              = optional(string)<br/>    role_description       = optional(string)<br/>    assign_as_cluster_role = optional(bool, false)<br/>    session_duration_limit = optional(number)<br/>    role_path              = optional(string)<br/>    attached_policy_arns   = optional(list(string), [])<br/>    assume_role_policy = object({<br/>      Version   = optional(string, "2012-10-17")<br/>      Statement = list(any)<br/>    })<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_role_arn"></a> [cluster\_role\_arn](#output\_cluster\_role\_arn) | n/a |
| <a name="output_node_group_role_arn"></a> [node\_group\_role\_arn](#output\_node\_group\_role\_arn) | n/a |
<!-- END_TF_DOCS -->