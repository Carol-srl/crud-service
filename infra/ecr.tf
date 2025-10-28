resource "aws_ecr_repository" "this" {
  name         = "carol/crud-service"
  force_delete = true
}
