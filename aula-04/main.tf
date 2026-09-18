# main.tf - Infraestrutura VPC + EC2 Multi-AZ da TechNova (Aula 04)

# =============================================================
# DATA SOURCE — AMI mais recente da Amazon Linux 2023
# =============================================================
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

# =============================================================
# VPC
# =============================================================
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "technova-vpc"
  }
}

# =============================================================
# SUBNETS — 2 públicas + 2 privadas, em 2 AZs diferentes
# =============================================================
resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "technova-public-subnet-${count.index + 1}"
    Type = "public"
  }
}

resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "technova-private-subnet-${count.index + 1}"
    Type = "private"
  }
}

# =============================================================
# INTERNET GATEWAY
# =============================================================
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "technova-igw"
  }
}

# =============================================================
# ROUTE TABLE PÚBLICA + ASSOCIAÇÕES
# (subnets privadas usam a Route Table padrão da VPC, sem rota para a internet)
# =============================================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "technova-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# =============================================================
# SECURITY GROUPS
# =============================================================

# SG da API — SSH (22) e API Node.js (3000) públicos
resource "aws_security_group" "api" {
  name        = "technova-api-sg"
  description = "Security group para a API TechNova - permite HTTP (3000) e SSH (22)"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "API Node.js"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "technova-api-sg"
  }
}

# SG do banco de dados (futuro) — PostgreSQL apenas de dentro da VPC
resource "aws_security_group" "db" {
  name        = "technova-db-sg"
  description = "Security group para o banco de dados - acesso apenas da VPC"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "PostgreSQL from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "technova-db-sg"
  }
}

# =============================================================
# KEY PAIR — registra a chave pública SSH gerada localmente
# (rode `ssh-keygen -t rsa -b 4096 -f ~/.ssh/technova-key -N ""` antes do apply)
# =============================================================
resource "aws_key_pair" "main" {
  key_name   = "technova-key"
  public_key = file(pathexpand(var.key_pair_public_key_path))

  tags = {
    Name = "technova-key"
  }
}

# =============================================================
# EC2 — API na subnet pública
# NOTA IMPORTANTE: o AWS Academy Learner Lab BLOQUEIA a criação de
# aws_iam_role / aws_iam_instance_profile. Por isso usamos o
# instance profile já existente no Learner Lab: "LabInstanceProfile"
# (que contém a LabRole com AmazonS3ReadOnlyAccess, entre outras).
# =============================================================
resource "aws_instance" "api" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.api.id]
  key_name               = aws_key_pair.main.key_name
  iam_instance_profile   = "LabInstanceProfile"

  user_data = file("${path.module}/user_data.sh")

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }

  tags = {
    Name = "technova-ec2-api"
  }
}