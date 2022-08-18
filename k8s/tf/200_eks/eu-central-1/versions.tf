terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.26.0, < 4.27"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6.0, < 2.7"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.12.1, < 2.13"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.2.3, < 2.3"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.1.1, < 3.2"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.3.2, < 3.4"
    }
  }
  required_version = ">= 1.2.7, < 1.3"
}
