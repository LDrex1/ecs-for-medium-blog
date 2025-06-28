variable "vpc_id" {
  type        = string
  description = "vpc id to which route table is associated"
}

variable "route_table_name" {
  type        = string
  description = "name tag of route table"
}

variable "route" {
  type = object({
    cidr_block = string
    gateway_id = string
  })
  description = "route specification"

  validation {
    condition     = can(cidrhost(var.route.cidr_block, 0))
    error_message = "wrong cidr block in route specification"
  }
}