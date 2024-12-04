variable "template" {
  description = "Template para uso dentro do módulo de EKS"
  type = object({
    name     = string
    role_arn = string
    version  = optional(string, "1.31")
    vpc_config = object({
      subnet_ids                       = list(string)
      endpoint_private_access          = optional(bool, false)
      endpoint_public_access           = optional(bool, true)
      public_access_cidrs              = optional(set(string), ["0.0.0.0/0"])
      control_plane_security_group_ids = optional(set(string))
    })
    access_config = optional(object({
      authentication_mode = string
    }), { authentication_mode = "API_AND_CONFIG_MAP" })
    upgrade_policy = optional(object({
      extended = bool
    }), { extended = false })
    irsa = optional(object({
      enable    = optional(bool, true)
      role_name = optional(string, "")
    }), { enable = false })
    # TODO: Popular e Criar o Resource
    node_groups = optional(list(object({
      name       = string
      role_arn   = string
      subnet_ids = list(string)
      scaling_config = object({
        desired_size = number
        max_size     = number
        min_size     = number
      })
      update_config = object({
        max_unavailable = number
      })
    })))
    access_entries = optional(list(object({
      principal_arn     = string
      type              = string
      user_name         = optional(string)
      kubernetes_groups = optional(list(string))
      policy_association = optional(list(object({
        scope      = string
        policy_arn = string
      })), [])
    })), [])
  })

  # Validação dos valores presentes no access_config
  validation {
    condition     = contains(["API_AND_CONFIG_MAP", "API", "CONFIG_MAP"], upper(var.template.access_config.authentication_mode))
    error_message = "O valor para o 'access_config' deve ser um dos seguintes valores: 'API_AND_CONFIG_MAP', 'API' ou 'CONFIG_MAP'"
  }
}
