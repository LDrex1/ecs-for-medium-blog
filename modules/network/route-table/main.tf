resource "aws_route_table" "public_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = var.route.cidr_block
    gateway_id = var.route.gateway_id
  }

  tags = {
    Name = var.route_table_name
  }
}

resource "aws_route_table_association" "public_route_association" {
  route_table_id = aws_route_table.public_route_table.id
  #   subnet_id = module.
}

