terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~>2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2"
    }
    local = {
      source = "hashicorp/local"
    }
    null = {
      source = "hashicorp/null"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  required_version = ">= 1.0.0"
}
