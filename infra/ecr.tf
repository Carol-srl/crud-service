resource "aws_ecr_repository" "carol_nest" {
  name = "carol/crud-service"
  force_delete = true
}