#S3 BUCKET
resource "aws_s3_bucket" "crud_service_config" {
  bucket = "carol-crud-service-definitions"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "crud_service_config" {
  bucket = aws_s3_bucket.crud_service_config.id
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}
