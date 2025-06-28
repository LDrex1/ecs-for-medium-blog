resource "aws_internet_gateway" "ig_gateway" {
  vpc_id = var.vpc_id

  tags = {
    Name = var.ig_name
  }
}