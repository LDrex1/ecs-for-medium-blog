variable "cluster_name" {
  type    = string
  default = "ecs-cluser"
}

variable "service_name" {
  type    = string
  default = "ecs-service"
}

variable "ecs_lunch_type" {
  type    = string
  default = "EC2"
}

variable "ecs_scheduling_strategy" {
  type    = string
  default = "REPLICA"
}

variable "service_count" {
  type    = string
  default = "2"
}

variable "ecs_task_family_name" {
  type = string
}

variable "ecs_requires_compatibilities" {
  type    = list(string)
  default = ["EC2"]
  validation {
    condition = length(var.ecs_requires_compatibilities) <= 2 && alltrue([for each in var.ecs_requires_compatibilities :
    each == "FARGATE" || each == "EC2"])
    error_message = "value"
  }
}

variable "ecs_task_memory" {
  type    = string
  default = "512"
}

variable "ecs_task_cpu" {
  type    = string
  default = "256"
}

# variable "ecs_container_definitions" {
#   type = map(any)
# }

variable "ecs_service_name" {
  type    = string
  default = "ecs-service"
}

variable "ecs_services" {
  type = list(object({
    name          = string
    task_family   = string
    task_cpu      = optional(string, "256")
    task_memory   = optional(string, "512")
    desired_count = optional(number, 1)
    containers = list(object({
      name      = string
      image     = string
      cpu       = optional(number, 256)
      memory    = optional(number, 512)
      essential = optional(bool, true)
      port_mappings = optional(list(object({
        containerPort = number
        protocol      = string
      })), [])
    }))
    assign_public_ip = optional(bool, false)
  }))
  description = "Definitions for each ECS service and its containers"
}

variable "ecs_service_subnet_ids" {
  type = list(string)
}

variable "default_container_port" {
  type = number
}

variable "ecs_vpc_id" {
  type = string
}

variable "ecs_sg_ids" {
  type    = list(string)
  default = []
}

variable "ecs_loadbalancer_arn" {
  type = string
}

variable "task_execution_role_name" {
  type    = string
  default = "ecsExecutionRole"
}

variable "task_execution_policy_arn" {
  type        = string
  default     = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  description = "Managed policy ARN for ECS task execution"
}