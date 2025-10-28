resource "aws_ecs_task_definition" "this" {
  family                   = "crud-service"
  execution_role_arn       = data.terraform_remote_state.main_infra.outputs.ecs_task_execution_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 2048
  container_definitions = jsonencode([
    {
      name      = "crud-service"
      image     = var.image
      essential = true

      portMappings = [
        {
          containerPort = var.port
          protocol      = "tcp"
        }
      ]

      secrets = [
        { name = "MONGODB_URL", valueFrom = data.aws_secretsmanager_secret.mongodb_url_metadata.arn },
      ]

      environment = [
        { name = "ENV", value = var.SERVICE_ENV[var.ENV] },
        { name = "HTTP_PORT", value = tostring(var.port) },
        { name = "LOG_LEVEL", value = var.LOG_LEVEL[var.ENV] },
        { name = "COLLECTION_DEFINITION_FOLDER", value = var.COLLECTION_DEFINITION_FOLDER },
        { name = "VIEWS_DEFINITION_FOLDER", value = var.VIEWS_DEFINITION_FOLDER },
        { name = "USER_ID_HEADER_KEY", value = var.USER_ID_HEADER_KEY },
        { name = "CRUD_LIMIT_CONSTRAINT_ENABLED", value = tostring(var.CRUD_LIMIT_CONSTRAINT_ENABLED) },
        { name = "CRUD_MAX_LIMIT", value = tostring(var.CRUD_MAX_LIMIT) },
        { name = "S3_BUCKET", value = "carol-crud-service-definitions" },
        { name = "S3_REGION", value = "eu-west-3" },
        { name = "S3_USE_IAM_ROLE", value = "true" }
      ]

      healthCheck = {
        command = [
          "CMD-SHELL", "exit 0",
        ]
        interval    = 30
        retries     = 3
        startPeriod = 60
        timeout     = 5
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.carol_log_group.name
          "awslogs-region"        = "eu-west-3"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = "crud"
  cluster         = data.terraform_remote_state.main_infra.outputs.ecs_cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.task_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.terraform_remote_state.main_infra.outputs.private_subnets
    assign_public_ip = false
    security_groups  = [data.terraform_remote_state.main_infra.outputs.ecs_security_group_id]
  }

}
