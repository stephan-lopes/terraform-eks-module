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
| <a name="module_irsa"></a> [irsa](#module\_irsa) | ./irsa | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eks_access_entry.this](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/eks_access_entry) | resource |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/eks_cluster) | resource |
| [aws_eks_node_group.this](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/eks_node_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_template"></a> [template](#input\_template) | Template para uso dentro do módulo de EKS | <pre>object({<br/>    name     = string<br/>    role_arn = string<br/>    version  = optional(string, "1.31")<br/>    vpc_config = object({<br/>      subnet_ids                       = list(string)<br/>      endpoint_private_access          = optional(bool, false)<br/>      endpoint_public_access           = optional(bool, true)<br/>      public_access_cidrs              = optional(set(string), ["0.0.0.0/0"])<br/>      control_plane_security_group_ids = optional(set(string))<br/>    })<br/>    access_config = optional(object({<br/>      authentication_mode = string<br/>    }), { authentication_mode = "API_AND_CONFIG_MAP" })<br/>    upgrade_policy = optional(object({<br/>      extended = bool<br/>    }), { extended = false })<br/>    irsa = optional(object({<br/>      enable    = optional(bool, true)<br/>      role_name = optional(string, "")<br/>    }), { enable = false })<br/>    # TODO: Popular e Criar o Resource<br/>    node_groups = optional(list(object({<br/>      name       = string<br/>      role_arn   = string<br/>      subnet_ids = list(string)<br/>      scaling_config = object({<br/>        desired_size = number<br/>        max_size     = number<br/>        min_size     = number<br/>      })<br/>      update_config = object({<br/>        max_unavailable = number<br/>      })<br/>    })))<br/>    access_entries = optional(list(object({<br/>      principal_arn     = string<br/>      type              = string<br/>      user_name         = optional(string)<br/>      kubernetes_groups = optional(list(string))<br/>    })), [])<br/>  })</pre> | n/a | yes |
<!-- END_TF_DOCS -->