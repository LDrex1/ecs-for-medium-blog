data "aws_availability_zones" "availabile" {

}

module "vpc" {
  source = "../../../modules/network/vpc"

  vpc_name                = var.vpc_name
  ig_name                 = var.ig_name
  vpc_availiability_zones = data.aws_availability_zones.availabile.zone_ids
  vpc_cidr                = var.vpc_cidr
  public_subnets          = var.public_subnets
  private_subnets         = var.private_subnets

  vpc_tags = var.vpc_tags

}

provider "aws" {
  region = "eu-west-2"
}

module "ecs" {
  source = "../../../modules/compute/ecs"

  ecs_task_family_name   = var.ecs_task_family_name
  ecs_services           = var.ecs_services
  default_container_port = 80
  ecs_loadbalancer_arn   = aws_elb.ecs.arn
  ecs_vpc_id             = module.vpc.vpc_id
  ecs_service_subnet_ids = module.vpc.public_subnet_id
  ecs_lunch_type = "FARGATE"

}

resource "aws_elb" "ecs" {
  name = "ecs-elb"
  availability_zones = data.aws_availability_zones.availabile.names

  listener {
    instance_port = 443
    instance_protocol = "http"
    lb_port            = 443
    lb_protocol        = "https"
  }
}