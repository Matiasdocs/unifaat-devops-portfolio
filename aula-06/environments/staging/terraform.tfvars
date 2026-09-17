# environments/staging/terraform.tfvars

aws_region   = "us-east-1"
project_name = "technova"
environment  = "staging"

vpc_cidr = "10.1.0.0/16"

subnets = {
  "public-1" = {
    cidr = "10.1.1.0/24"
    az   = "us-east-1a"
    type = "public"
  }
  "public-2" = {
    cidr = "10.1.2.0/24"
    az   = "us-east-1b"
    type = "public"
  }
  "private-1" = {
    cidr = "10.1.3.0/24"
    az   = "us-east-1a"
    type = "private"
  }
  "private-2" = {
    cidr = "10.1.4.0/24"
    az   = "us-east-1b"
    type = "private"
  }
}

# Deixe "" para usar automaticamente a AMI mais recente da Amazon Linux 2023
ami_id        = ""
instance_type = "t2.micro"

# Troque pelo nome do seu key pair (crie um no Learner Lab se ainda não tiver)
key_name = "technova-key"

db_name           = "technova_staging"
db_username       = "technova_admin"
db_password       = "TechNovaStg2026Senha"
db_instance_class = "db.t3.micro"
