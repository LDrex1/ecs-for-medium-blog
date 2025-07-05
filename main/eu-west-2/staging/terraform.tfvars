vpc_name        = "Staging-amh-vpc"
ig_name         = "staging_ig"
vpc_cidr        = "10.2.0.0/20"
public_subnets  = ["10.2.0.0/22"]
private_subnets = ["10.2.4.0/22", "10.2.8.0/22"]

vpc_tags = {
  enviroment = "staging"
  source     = "terraform"
}

ecs_task_family_name = "Medium-task"
ecs_services = [{
  name        = "fullstack app"
  task_family = "fullstack-task"
  containers = [{
    name  = "database-container-service"
    image = "mongo:noble"
    port_mappings = [{
      containerPort = 2307
      protocol      = "tcp"
    }]
  }]
}]