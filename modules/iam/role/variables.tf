variable "role" {
  type = object({
    name                 = optional(string)
    name_prefix          = optional(string)
    description          = optional(string)
    max_session_duration = optional(number)
    path                 = optional(string)
    assume_role_policy   = string
  })

  default = {
    name                 = null
    name_prefix          = null
    description          = null
    max_session_duration = null
    path                 = "/"
    assume_role_policy   = null
  }

}
