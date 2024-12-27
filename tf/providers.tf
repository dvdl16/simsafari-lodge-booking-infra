terraform {
  required_version = "~> 1.10.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82"
    }
  }

  backend "s3" {
    bucket = "onsjabulani-terraform"
    key    = "prod/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  alias  = "acm_provider"
  region = "us-east-1"
}