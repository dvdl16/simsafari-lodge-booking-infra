terraform {
  required_version = "~> 1.5.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "onsjabulani-terraform"
    key    = "prod/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  alias   = "acm_provider"
  region  = "us-east-1"
  # access_key = var.aws_access_key
  # secret_key = var.aws_secret_key
}