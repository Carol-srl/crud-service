terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.99.1"
    }
  }

  # Configure the backend to store THIS Terraform state file in an S3 bucket
  backend "s3" {
    bucket       = "carol-terraform-remotestate"
    key          = "crud-service/terraform.tfstate"
    region       = "eu-west-3"
    encrypt      = true
    use_lockfile = true
  }
}
