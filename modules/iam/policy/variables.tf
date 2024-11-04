variable "policy" {
  type = object({
    name        = optional(string)
    name_prefix = optional(string)
    description = optional(string)
    path        = optional(string)
    policy      = string
  })

  default = {
    name        = ""
    name_prefix = ""
    description = ""
    path        = "/"
    policy      = null
  }

}
