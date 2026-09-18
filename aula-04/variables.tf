# variables.tf - Variáveis do projeto

variable "aws_region" {
  description = "Região AWS para criar os recursos"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto (usado em tags e nomes de recursos)"
  type        = string
  default     = "technova"
}

variable "ra" {
  description = "RA do aluno (tag Owner)"
  type        = string
  default     = "6325053"
}

variable "aluno_nome" {
  description = "Nome do aluno (tag Aluno)"
  type        = string
  default     = "Matheus Gabriel Correa Braga Viana"
}

variable "vpc_cidr" {
  description = "Bloco CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones usadas (Multi-AZ) — uma por par de subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDRs das subnets públicas (uma por AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs das subnets privadas (uma por AZ)"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.4.0/24"]
}

variable "instance_type" {
  description = "Tipo da instância EC2 (mantenha t2.micro para Free Tier)"
  type        = string
  default     = "t2.micro"
}

variable "key_pair_public_key_path" {
  description = "Caminho local da chave pública SSH (gerada com ssh-keygen)"
  type        = string
  default     = "~/.ssh/technova-key.pub"
}