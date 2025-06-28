variable "vpc_id" {
  type        = string
  description = "vpc id by which the nacl is associated with"
}

variable "ingress_rule" {
  type = list(object({
    protocol   = number
    rule_no    = number
    action     = "allow" || "deny"
    cidr_block = string
    from_port  = number
    to_port    = number
  }))

  validation {
    condition     = can(cidrhost(var.ingress_rule.cidr_block, 0))
    error_message = "Invalid CIDR block for IPv4 address"
  }
}
variable "egress_rule" {
  type = list(object({
    protocol   = number
    rule_no    = number
    action     = "allow" || "deny"
    cidr_block = string
    from_port  = number
    to_port    = number
  }))

  validation {
    condition     = can(cidrhost(var.ingress_rule.cidr_block, 0))
    error_message = "Invalid CIDR block for IPv4 address"
  }
}