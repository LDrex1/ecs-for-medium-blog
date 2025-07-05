resource "aws_ecs_cluster" "this" {
  name = var.cluster_name

}

resource "aws_ecs_task_definition" "this" {
  for_each                 = { for svc in var.ecs_services : svc.name => svc }
  family                   = each.value.task_family
  network_mode             = "awsvpc"
  requires_compatibilities = var.ecs_requires_compatibilities
  memory                   = each.value.task_memory
  cpu                      = each.value.task_cpu

  container_definitions = jsonencode([for c in each.value.containers : merge(
    {
      name      = c.name
      essential = lookup(c, "essential", true)
    },
    c.port_mappings == [] ? {} : { port_mappings = c.port_mappings },
    { image = c.image, cpu = c.cpu, memory = c.memory }
  )])

}

locals {
  svc_counts = { for svc in var.ecs_services : svc.name => svc.desired_count }
}

resource "aws_ecs_service" "this" {
  for_each = aws_ecs_task_definition.this

  name                = each.key
  cluster             = aws_ecs_cluster.this.id
  launch_type         = var.ecs_lunch_type
  scheduling_strategy = var.ecs_scheduling_strategy
  desired_count       = lookup(local.svc_counts, each.key, 1)
  task_definition     = each.value.arn

  network_configuration {
    subnets          = var.ecs_service_subnet_ids
    assign_public_ip = false
    security_groups  = var.ecs_sg_ids
  }

  depends_on = [aws_lb_target_group.this]
}

resource "aws_lb_target_group" "this" {
  name     = "${var.ecs_service_name}-tg"
  port     = var.default_container_port
  protocol = "HTTP"
  vpc_id   = var.ecs_vpc_id

  health_check {
    path                = "/"
    interval            = 180
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = var.ecs_loadbalancer_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "foward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# IAM Role for Task Execution
resource "aws_iam_role" "task_execution" {
  name               = var.task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.task_exec_assume.json
}

data "aws_iam_policy_document" "task_exec_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# Attach managed execution policy
resource "aws_iam_role_policy_attachment" "exec_attach" {
  role       = aws_iam_role.task_execution.name
  policy_arn = var.task_execution_policy_arn
}

