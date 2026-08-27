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
  region = "us-east-1"

  default_tags {
    tags = {
      Project    = "TechNova"
      ManagedBy  = "Terraform"
      Aluno      = "Matheus Gabriel Correa Braga Viana"
      RA         = "6325053"
      Disciplina = "DevOps - UniFAAT 2026-2"
      Aula       = "03"
    }
  }
}