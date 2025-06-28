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
