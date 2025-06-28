resource "aws_ecs_service" "backend_service" {
  name                = "fast-api-service"
  cluster             = aws_ecs_cluster.backend-cluster.id
  task_definition     = aws_ecs_task_definition.backend_api_task.arn
  launch_type         = "EC2"
  scheduling_strategy = "REPLICA"
  desired_count       = 1

  network_configuration {
    subnets          = [aws_default_subnet.ecs_az1.id]
    assign_public_ip = false
  }
}