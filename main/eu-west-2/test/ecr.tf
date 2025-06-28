resource "aws_ecr_repository" "test_repo" {
  name = "test-repo"

  tags = {
    Name   = "latest_ecr"
    Source = "Terraform-1"
  }
}