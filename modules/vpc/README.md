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

## Resources

| Name | Type |
|------|------|
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/eip) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/nat_gateway) | resource |
| [aws_route.this](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/route) | resource |
| [aws_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/route_table) | resource |
| [aws_route_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/route_table_association) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/security_group) | resource |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/vpc) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/data-sources/security_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_template"></a> [template](#input\_template) | n/a | <pre>object({<br/><br/>    internet_gateway = optional(object({<br/>      name   = optional(string, "eks")<br/>      enable = optional(bool, true)<br/>    }), { enable = false })<br/><br/>    nat_gateway = optional(object({<br/>      name   = optional(string, "eks")<br/>      enable = optional(bool, true)<br/>    }), { enable = false })<br/><br/>    vpc = object({<br/>      cidr                 = optional(string, "10.0.0.0/16")<br/>      name                 = string<br/>      tenancy              = optional(string, "default")<br/>      enable_dns_hostnames = optional(bool, false)<br/>      enable_dns_support   = optional(bool, false)<br/>    })<br/><br/>    subnets = list(object({<br/>      name              = string<br/>      availability_zone = string<br/>      cidr_block        = string<br/>      public_subnet     = optional(bool, false)<br/>    }))<br/><br/>    security_groups = optional(list(object({<br/>      name        = string<br/>      description = string<br/>      ingress_rules = optional(list(object({<br/>        description           = optional(string)<br/>        from_port             = number<br/>        to_port               = number<br/>        protocol              = string<br/>        security_groups_names = optional(set(string), [])<br/>        cidr_blocks           = optional(list(string), [])<br/>        self                  = optional(bool, false)<br/>      })))<br/>      egress_rules = optional(list(object({<br/>        description           = optional(string)<br/>        from_port             = number<br/>        to_port               = number<br/>        protocol              = string<br/>        security_groups_names = optional(set(string), [])<br/>        cidr_blocks           = optional(list(string), [])<br/>        self                  = optional(bool, false)<br/>      })))<br/>    })), [])<br/><br/>    route_table = optional(object({<br/>      routes = list(object({<br/>        description      = optional(string)<br/>        route_table_type = optional(string, "private")<br/>        destination      = string<br/>        target = object({<br/>          internet_gateway = optional(bool, false)<br/>          nat_gateway      = optional(bool, false)<br/>          local_gateway    = optional(bool, false)<br/>        })<br/>      }))<br/>    }))<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_subnets_ids"></a> [private\_subnets\_ids](#output\_private\_subnets\_ids) | n/a |
| <a name="output_public_subnets_ids"></a> [public\_subnets\_ids](#output\_public\_subnets\_ids) | n/a |
| <a name="output_security_groups_ids"></a> [security\_groups\_ids](#output\_security\_groups\_ids) | n/a |
<!-- END_TF_DOCS -->