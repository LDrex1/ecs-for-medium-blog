resource "aws_default_vpc" "ecs-vpc" {
  tags = {
    Name     = "ECS-VPC"
    Deployer = "Terraform-1"
  }
}

resource "aws_default_subnet" "ecs_az1" {
  availability_zone = "eu-west-2a"

  tags = {
    Name = "Default subnet for eu-west-2a"
  }
}

resource "aws_default_subnet" "ecs_az2" {
  availability_zone = "eu-west-2b"

  tags = {
    Name = "Default subnet for eu-west-2b"
  }
}

resource "aws_default_subnet" "ecs_az3" {
  availability_zone = "eu-west-2c"

  tags = {
    Name = "Default subnet for eu-west-2c"
  }
}