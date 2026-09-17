# environments/dev/main.tf
# Composição de módulos: VPC -> Security Groups -> EC2 / RDS

# ========================================
# Data source: AMI mais recente da Amazon Linux 2023
# Evita fixar um AMI ID que fica desatualizado/inválido com o tempo.
# ========================================
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ========================================
# Módulo 1: VPC (base de tudo)
# ========================================
module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr     = var.vpc_cidr
  project_name = var.project_name
  environment  = var.environment
  subnets      = var.subnets
}

# ========================================
# Módulo 2: Security Group da API
# (recebe vpc_id do módulo VPC — composição!)
# ========================================
module "api_sg" {
  source = "../../modules/security-group"

  name           = "${var.project_name}-${var.environment}-api-sg"
  sg_description = "Security Group da API - HTTP, HTTPS e SSH"
  vpc_id         = module.vpc.vpc_id
  environment    = var.environment
  project_name   = var.project_name

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "SSH"
    }
  ]
}

# ========================================
# Módulo 3: Security Group do RDS
# (recebe vpc_id do módulo VPC — composição!)
# ========================================
module "rds_sg" {
  source = "../../modules/security-group"

  name           = "${var.project_name}-${var.environment}-rds-sg"
  sg_description = "Security Group do RDS - PostgreSQL apenas da VPC"
  vpc_id         = module.vpc.vpc_id
  environment    = var.environment
  project_name   = var.project_name

  ingress_rules = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
      description = "PostgreSQL from VPC"
    }
  ]
}

# ========================================
# Módulo 4: EC2 (API server)
# (recebe subnet_id do VPC e sg_id do SG — composição!)
# ========================================
module "api_server" {
  source = "../../modules/ec2"

  instance_name      = "${var.project_name}-${var.environment}-api"
  instance_type      = var.instance_type
  ami_id             = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [module.api_sg.sg_id]
  key_name           = var.key_name
  environment        = var.environment
  project_name       = var.project_name
}

# ========================================
# Módulo 5: RDS (banco de dados)
# (recebe subnet_ids do VPC e sg_id do SG — composição!)
# ========================================
module "database" {
  source = "../../modules/rds"

  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.rds_sg.sg_id]
  instance_class     = var.db_instance_class
  environment        = var.environment
  project_name       = var.project_name
}
