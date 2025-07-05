output "ecs_cluster_id" {
  value       = aws_ecs_cluster.this.id
  description = "The ECS cluster id"
}

output "ecs_service_arn" {
  value       = [for key, svc in aws_ecs_service.this : svc.id]
  description = "ECS service ARN"
}

output "taskdefinition_arn" {
  value = [for key, t in aws_ecs_task_definition.this : t.arn]
}