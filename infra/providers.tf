terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket = "threatmod-tfstate"
    key    = "dev/terraform.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
  tags = {
    Environment = "dev"
    Project     = "threatmod"
    ManagedBy   = "Terraform"
    }
  }
}

