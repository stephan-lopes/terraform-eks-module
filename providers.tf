terraform {
  required_version = ">= 1.9.8"

  backend "s3" {
    bucket         = "aws-guiaanonima-tfstate"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "aws-guiaanonima-tfstate"
  }


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.74.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "guia-anonima"
}
