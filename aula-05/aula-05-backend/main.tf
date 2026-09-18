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
      Project = "TechNova"
      Purpose = "Terraform Remote State"
      Owner   = "6325053"
    }
  }
}

variable "bucket_name" {
  description = "Nome do bucket S3 (criado via CLI antes do apply)"
  type        = string
  default     = "technova-tfstate-6325053"
}
