data "aws_secretsmanager_secret" "mongodb_url_metadata" {
  name = "mongodb_url_${var.ENV}"
}
