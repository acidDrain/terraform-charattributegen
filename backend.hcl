terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.5.0"
    }
  }
  cloud {
    organization = "elasticplayground"
    workspaces {
      name = "terraform-charattributegen"
    }
  }
}
