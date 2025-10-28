# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "carol_log_group" {
  name              = "/ecs/crud-service"
  retention_in_days = 30

  tags = {
    Name = "carol-log-group"
  }
}
