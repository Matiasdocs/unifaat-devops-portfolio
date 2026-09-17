# modules/ec2/variables.tf

variable "instance_name" {
  description = "Nome da instância EC2 (usado em tags)"
  type        = string
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID a ser usada pela instância"
  type        = string
}

variable "subnet_id" {
  description = "ID da subnet onde a instância será criada"
  type        = string
}

variable "security_group_ids" {
  description = "Lista de Security Group IDs associados à instância"
  type        = list(string)
}

variable "key_name" {
  description = "Nome do key pair usado para acesso SSH (opcional)"
  type        = string
  default     = null
}

variable "user_data" {
  description = "Script de inicialização (user data) opcional"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto (usado em tags)"
  type        = string
}
