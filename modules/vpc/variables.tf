variable "template" {
  type = object({

    internet_gateway = optional(object({
      name   = optional(string, "eks")
      enable = optional(bool, true)
    }), { enable = false })

    nat_gateway = optional(object({
      name   = optional(string, "eks")
      enable = optional(bool, true)
    }), { enable = false })

    vpc = object({
      cidr                 = optional(string, "10.0.0.0/16")
      name                 = string
      tenancy              = optional(string, "default")
      enable_dns_hostnames = optional(bool, false)
      enable_dns_support   = optional(bool, false)
    })

    subnets = list(object({
      name              = string
      availability_zone = string
      cidr_block        = string
      public_subnet     = optional(bool, false)
    }))

    security_groups = optional(list(object({
      name        = string
      description = string
      ingress_rules = optional(list(object({
        description           = optional(string)
        from_port             = number
        to_port               = number
        protocol              = string
        security_groups_names = optional(set(string), [])
        cidr_blocks           = optional(list(string), [])
        self                  = optional(bool, false)
      })))
      egress_rules = optional(list(object({
        description           = optional(string)
        from_port             = number
        to_port               = number
        protocol              = string
        security_groups_names = optional(set(string), [])
        cidr_blocks           = optional(list(string), [])
        self                  = optional(bool, false)
      })))
    })), [])

    route_table = optional(object({
      routes = list(object({
        description      = optional(string)
        route_table_type = optional(string, "private")
        destination      = string
        target = object({
          internet_gateway = optional(bool, false)
          nat_gateway      = optional(bool, false)
          local_gateway    = optional(bool, false)
        })
      }))
    }))
  })


  validation {
    condition = var.template.route_table == null ? true : alltrue([
      for route in var.template.route_table.routes : (
        (route.target.internet_gateway ? 1 : 0) +
        (route.target.nat_gateway ? 1 : 0) +
        (route.target.local_gateway ? 1 : 0) == 1
      )
    ])
    error_message = "Em cada rota, apenas um dos valores 'internet_gateway' ou 'nat_gateway' deve ser 'true'."
  }

  validation {
    condition = var.template.security_groups == [] ? true : alltrue([
      for sg in var.template.security_groups : alltrue([
        for ingress in sg.ingress_rules : (
          (length(ingress.security_groups) > 0 ? 1 : 0) +
          (length(ingress.cidr_blocks) > 0 ? 1 : 0) +
          (ingress.self ? 1 : 0) == 1
        )
      ])
    ])
    error_message = "Em cada grupo de segurança, apenas uma das entradas 'security_groups' ou 'cidr_blocks' deve ser passada como argumento."
  }

  validation {
    condition = var.template.security_groups == [] ? true : alltrue([
      for sg in var.template.security_groups : alltrue([
        for egress in sg.egress_rules : (
          (length(egress.security_groups) > 0 ? 1 : 0) +
          (length(egress.cidr_blocks) > 0 ? 1 : 0) +
          (egress.self ? 1 : 0) == 1
        )
      ])
    ])
    error_message = "Em cada grupo de segurança, apenas uma das entradas 'security_groups' ou 'cidr_blocks' deve ser passada como argumento."
  }

  validation {
    condition = var.template.route_table == null ? true : alltrue([
      for route in var.template.route_table.routes : true if route.route_table_type == "private" || route.route_table_type == "public"
    ])
    error_message = "Os tipos de route_table_type aceitos são apenas: 'private' e 'public'"
  }
}
