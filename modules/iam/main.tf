resource "aws_iam_role" "this" {
    name = var.name
  assume_role_policy = jsondecode(var.assume_role_policy)

  tags = var.role_tags
}