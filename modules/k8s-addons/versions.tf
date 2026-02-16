terraform {
  required_version = ">= 1.10.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.15.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.32.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}
