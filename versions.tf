terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    massdriver = {
      source  = "massdriver-cloud/massdriver"
      version = ">= 1.0"
    }
  }
}
