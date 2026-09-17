# environments/dev/providers.tf

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Aluno       = "Matheus Gabriel Correa Braga Viana"
      RA          = "6325053"
      Disciplina  = "DevOps - UniFAAT 2026-2"
      Aula        = "06"
    }
  }
}
