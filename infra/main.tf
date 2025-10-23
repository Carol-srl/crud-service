# Tell Terraform to READ the remote state of the main infrastructure
# from the S3 bucket, so that we can use the outputs in this module.
data "terraform_remote_state" "main_infra" {
  backend = "s3"
  config = {
    bucket = "carol-terraform-remotestate"
    key    = "main-infra/terraform.tfstate"
    region = "eu-west-3"
  }
}