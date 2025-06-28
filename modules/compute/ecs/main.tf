resource "aws_ecs_cluster" "this" {
  name = var.cluster_name

}

resource "aws_ecs_service" "name" {
  name = var.service_name
}

