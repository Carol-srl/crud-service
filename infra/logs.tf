
#LOGS
resource "aws_cloudwatch_log_group" "carol_log_group" {
  name              = "/ecs/crud-service"
  retention_in_days = 30

  tags = {
    Name = "carol-log-group"
  }
}

#resource "aws_cloudwatch_log_stream" "carol_log_stream" {
#  name           = "carol-log-stream"
#  log_group_name = aws_cloudwatch_log_group.carol_log_group.name
#}
