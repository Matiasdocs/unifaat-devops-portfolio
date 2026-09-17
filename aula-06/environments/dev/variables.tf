# environments/dev/variables.tf

variable "aws_region" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "technova"
}

variable "environment" {
  description = "Nome do ambiente"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
}

variable "subnets" {
  description = "Mapa de subnets do ambiente"
  type = map(object({
    cidr = string
    az   = string
    type = string
  }))
}

variable "ami_id" {
  description = "AMI ID para a instância EC2. Deixe em branco (\"\") para usar automaticamente a AMI mais recente da Amazon Linux 2023."
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nome do key pair para acesso SSH (opcional)"
  type        = string
  default     = null
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
}

variable "db_username" {
  description = "Usuário master do banco de dados"
  type        = string
}

variable "db_password" {
  description = "Senha master do banco de dados"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Classe da instância RDS"
  type        = string
  default     = "db.t3.micro"
}
