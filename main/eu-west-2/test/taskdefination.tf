resource "aws_ecs_task_definition" "backend_api_task" {
  family                = "backend-api-task"
  container_definitions = <<DEFINITION
  [
    {
        "name": "backend-api-task",
        "image": "${aws_ecr_repository.test_repo.repository_url}",
        "essential": true,
        "portMappings": [
            {
                "containerPort": 80,
                "hostPort": 80
            }
        ],
        "memory": 512,
        "cpu": 256,
        "networkMode": "awsvpc"
    }
  ]
  DEFINITION

  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole2.arn
  memory                   = 512
  cpu                      = 256
}