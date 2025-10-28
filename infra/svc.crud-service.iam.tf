resource "aws_iam_role" "crud_service_task_execution_role" {
  name = "crudServiceTaskExecutionRole"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "crud_service_task_execution_role_policy" {
  role       = aws_iam_role.crud_service_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "crud_service_s3_read" {
  name        = "crudServiceS3ReadPolicy"
  description = "Allow ECS task to read config files from S3 bucket"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.crud_service_config.arn,
          "${aws_s3_bucket.crud_service_config.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "crud_service_task_role" {
  name = "crudServiceTaskRole"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "crud_service_task_role_s3" {
  role       = aws_iam_role.crud_service_task_role.name
  policy_arn = aws_iam_policy.crud_service_s3_read.arn
}
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy_access_secretsmanager_attachment" {
  role       = aws_iam_role.crud_service_task_role.name
  policy_arn = "arn:aws:iam::972096737302:policy/ecs_task_execution_policy_access_secretsmanager"
}
