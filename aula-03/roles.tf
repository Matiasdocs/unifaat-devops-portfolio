# ========================================
# Service Role - EC2 -> S3
# ========================================

resource "aws_iam_role" "ec2_role" {
  name = "${var.ra}-technova-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project    = var.project_name
    ManagedBy  = "Terraform"
    Aluno      = var.aluno
    RA         = var.ra
    Disciplina = "DevOps - UniFAAT 2026-2"
    Aula       = "03"
  }
}

# ========================================
# Policy da Role - acesso ao S3
# technova-app-data-*
# ========================================

resource "aws_iam_policy" "ec2_s3_app_data" {
  name        = "${var.ra}-technova-ec2-s3-app-data"
  description = "Permite que instancias EC2 leiam e gravem dados nos buckets technova-app-data-*"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ListAppDataBuckets"
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = [
          "arn:aws:s3:::technova-app-data-*"
        ]
      },
      {
        Sid    = "ReadWriteAppDataObjects"
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]

        Resource = [
          "arn:aws:s3:::technova-app-data-*/*"
        ]
      }
    ]
  })

  tags = {
    Project    = var.project_name
    ManagedBy  = "Terraform"
    Aluno      = var.aluno
    RA         = var.ra
    Disciplina = "DevOps - UniFAAT 2026-2"
    Aula       = "03"
  }
}

# ========================================
# Anexa a policy à Role
# ========================================

resource "aws_iam_role_policy_attachment" "ec2_s3_app_data" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_s3_app_data.arn
}

# ========================================
# Instance Profile
# ========================================

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.ra}-technova-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = {
    Project    = var.project_name
    ManagedBy  = "Terraform"
    Aluno      = var.aluno
    RA         = var.ra
    Disciplina = "DevOps - UniFAAT 2026-2"
    Aula       = "03"
  }
}