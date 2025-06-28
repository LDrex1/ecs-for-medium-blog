resource "aws_network_acl" "name" {
  vpc_id = var.vpc_id

  ingress = var.ingress_rule
  egress  = var.egress_rule
}