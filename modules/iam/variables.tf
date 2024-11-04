variable "policies" {
  type = list(object({
    name        = optional(string)
    description = optional(string)
    path        = optional(string)
    roles       = optional(string)
    policy = object({
      Version = string
      Statement = list(object({
        Action   = list(string)
        Effect   = string
        Resource = string
      }))
    })
  }))

  default = []
}


variable "roles" {
  type = list(object({
    name                 = optional(string)
    description          = optional(string)
    max_session_duration = optional(number)
    path                 = optional(string)
    policy_arns          = optional(list(string), [])
    assume_role_policy = object({
      Version   = optional(string, "2012-10-17")
      Statement = list(any)
    })
  }))
}
