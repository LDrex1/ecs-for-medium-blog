resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = jsondecode(var.assume_role_policy)

  tags = var.role_tags
}