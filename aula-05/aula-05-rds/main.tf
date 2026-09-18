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
# VPC + Subnets (2 públicas, 2 privadas, 2 AZs)
# =============================================================
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "technova-vpc" }
}

resource "aws_subnet" "public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags                    = { Name = "technova-public-subnet-${count.index + 1}" }
}

resource "aws_subnet" "private" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags              = { Name = "technova-private-subnet-${count.index + 1}" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "technova-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "technova-public-rt" }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# =============================================================
# Security Groups
# =============================================================
resource "aws_security_group" "api" {
  name        = "technova-api-sg"
  description = "SSH para a instancia EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "technova-api-sg" }
}

resource "aws_security_group" "db" {
  name        = "technova-db-sg"
  description = "PostgreSQL apenas da VPC"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "PostgreSQL from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "technova-db-sg" }
}

# =============================================================
# Key Pair + EC2 (subnet publica, cliente psql)
# =============================================================
resource "aws_key_pair" "main" {
  key_name   = "technova-key"
  public_key = file(pathexpand(var.key_pair_public_key_path))
}

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

  tags = { Name = "technova-ec2-api" }
}

# =============================================================
# RDS (subnets privadas, 2 AZs)
# =============================================================
resource "aws_db_subnet_group" "main" {
  name       = "technova-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id
  tags       = { Name = "technova-db-subnet-group" }
}

resource "aws_db_instance" "main" {
  identifier     = "technova-db"
  engine         = "postgres"
  engine_version = "15"

  instance_class    = var.db_instance_class
  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false
  multi_az                = false

  skip_final_snapshot = true
  storage_encrypted    = true

  tags = { Name = "technova-db" }
}
