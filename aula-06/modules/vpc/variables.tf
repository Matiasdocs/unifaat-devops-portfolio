# modules/vpc/variables.tf

variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto (usado em tags e naming)"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "subnets" {
  description = "Mapa de subnets a serem criadas dinamicamente (chave = nome da subnet)"
  type = map(object({
    cidr = string
    az   = string
    type = string # "public" ou "private"
  }))
}
