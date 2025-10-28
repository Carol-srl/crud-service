#ECS SERVICE
resource "aws_ecs_service" "this" {
    name            = "crud"
    cluster         = data.terraform_remote_state.main_infra.outputs.ecs_cluster_id
    task_definition = aws_ecs_task_definition.this.arn
    desired_count   = var.task_count
    launch_type     = "FARGATE"
    platform_version = "1.4.0"

    network_configuration {
        security_groups  = [data.terraform_remote_state.main_infra.outputs.ecs_security_group_id]
        subnets          = data.terraform_remote_state.main_infra.outputs.private_subnets
        assign_public_ip = false
    }
    service_registries {
      registry_arn = aws_service_discovery_service.crud.arn
    }

    #load_balancer {
    #    target_group_arn = data.terraform_remote_state.main_infra.outputs.alb_target_group_backoffice_arn
    #    container_name   = "carol-api-gateway"
    #    container_port   = 80
    #}

}
resource "aws_ecs_task_definition" "this" {
    family                   = "crud"
    execution_role_arn       = aws_iam_role.crud_service_task_execution_role.arn
    task_role_arn            = aws_iam_role.crud_service_task_role.arn
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = 512
    memory                   = 2048
    container_definitions = jsonencode([
    {
      name      = "crud"
      image     = "${var.image}:${var.image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = var.port
          protocol      = "tcp"
          name          = "http-port"
        }
      ]

      healthCheck = {
        #command     = ["CMD-SHELL", "curl -f http://0.0.0.0:3000/-/healthz || exit 1"]
        command     = ["CMD-SHELL", "exit 0"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }

      secrets = [
        { name = "MONGODB_URL", valueFrom = data.aws_secretsmanager_secret.mongodb_url_metadata.arn },
      ]

      environment = [
        { name = "LOG_LEVEL", value = "debug" },
        { name = "COLLECTION_DEFINITION_FOLDER", value = "/home/node/app/disk/collections" },
        { name = "VIEWS_DEFINITION_FOLDER", value = "/home/node/app/disk/views" },
        { name = "USER_ID_HEADER_KEY", value = "userid" },
        { name = "CRUD_LIMIT_CONSTRAINT_ENABLED", value = "true" },
        { name = "CRUD_MAX_LIMIT", value = "200" },
        { name = "S3_BUCKET", value = "carol-crud-service-definitions" },
        { name = "S3_REGION", value = "eu-west-3" },
        { name = "S3_USE_IAM_ROLE", value = "true" }
      ]

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

resource "aws_service_discovery_service" "crud" {
 name = "crud"

 dns_config {
   namespace_id = data.terraform_remote_state.main_infra.outputs.service_discovery_namespace_id

   dns_records {
     ttl  = 20
     type = "A"
   }

   routing_policy = "MULTIVALUE"
 }
 
}

# TARGET GROUP AND LISTENER RULE
#resource "aws_alb_target_group" "crud" {
#  name        = "carol-crud-tg"
#  port        = 3000
#  protocol    = "HTTP"
#  vpc_id      = aws_vpc.main.id
#  target_type = "ip"
#
#  health_check {
#    healthy_threshold   = 3
#    interval            = 30
#    protocol            = "HTTP"
#    matcher             = "200"
#    timeout             = 3
#    path                = "/-/healthz"
#    unhealthy_threshold = 2
#  }
#}

#resource "aws_alb_listener_rule" "crud_host" {
#  count = 0 # Set to 0 to disable this rule by default, enable it when needed
#  listener_arn = aws_alb_listener.https.arn
#  priority     = 100
#  action {
#    type             = "forward"
#    target_group_arn = aws_alb_target_group.crud.arn
#  }
#  condition {
#    host_header {
#      values = ["crud.be.carol.health"]
#    }
#  }
#}