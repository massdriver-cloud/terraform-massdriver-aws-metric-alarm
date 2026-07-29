terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
    massdriver = {
      source  = "massdriver-cloud/massdriver"
      version = ">= 2.0"
    }
  }
}
