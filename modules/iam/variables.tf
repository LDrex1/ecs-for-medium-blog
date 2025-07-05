variable "role_name" {
  description = "role name"
  type        = string
  default     = "iam-role"
}

variable "assume_role_policy" {
  description = "Iam role assume policy in object form"
  type = object({
    Version = optional(string, "2012-10-17")
    Statement = list(object({
      Effect    = string
      Principal = map(any)
      Action    = list(string)
      Conditon  = optional(map(any))
    }))
  })
}

variable "role_tags" {
  type        = map(any)
  description = "role tags"
  default = {
  }
}