terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = ">= 5.10"
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4.0"
    }
  }

}

