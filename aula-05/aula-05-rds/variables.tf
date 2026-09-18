variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "technova"
}

variable "ra" {
  type    = string
  default = "6325053"
}

variable "aluno_nome" {
  type    = string
  default = "Matheus Gabriel Correa Braga Viana"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.2.0/24", "10.0.4.0/24"]
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_pair_public_key_path" {
  type    = string
  default = "~/.ssh/technova-key.pub"
}

variable "db_name" {
  type    = string
  default = "technova"
}

variable "db_username" {
  type    = string
  default = "technova_admin"
}

variable "db_password" {
  type      = string
  sensitive = true
  # Não coloque valor aqui! Passe via: terraform apply -var="db_password=SUA_SENHA"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}
