terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
  default_tags {
    tags = {
      ManagedByTerraform = "true"
      Creator            = "bae"
      Email              = "flos0422@gmail.com"
    }
  }
}