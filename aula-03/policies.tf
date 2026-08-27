# ========================================
# Policy 1 - S3 Read Only
# Developers podem listar buckets TechNova
# e ler objetos desses buckets.
# ========================================

resource "aws_iam_policy" "s3_read" {
  name        = "${var.ra}-technova-s3-read"
  description = "Permite leitura em buckets S3 technova-*"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ListTechNovaBuckets"
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = [
          "arn:aws:s3:::technova-*"
        ]
      },
      {
        Sid    = "ReadTechNovaObjects"
        Effect = "Allow"

        Action = [
          "s3:GetObject"
        ]

        Resource = [
          "arn:aws:s3:::technova-*/*"
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
# Policy 2 - EC2 + S3 para Platform Eng
# ========================================

resource "aws_iam_policy" "ec2_s3_full" {
  name        = "${var.ra}-technova-ec2-s3-full"
  description = "Permite gerenciamento controlado de EC2 e leitura/escrita no S3"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "DescribeEC2"
        Effect = "Allow"

        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeTags"
        ]

        Resource = "*"
      },
      {
        Sid    = "StartStopTechNovaInstances"
        Effect = "Allow"

        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances"
        ]

        Resource = "arn:aws:ec2:*:*:instance/*"

        Condition = {
          StringEquals = {
            "aws:ResourceTag/Project" = "TechNova"
          }
        }
      },
      {
        Sid    = "ListTechNovaS3"
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = [
          "arn:aws:s3:::technova-*"
        ]
      },
      {
        Sid    = "ReadWriteTechNovaS3"
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]

        Resource = [
          "arn:aws:s3:::technova-*/*"
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
# Policy 3 - Deny operações destrutivas
# Proteção adicional para Developers
# ========================================

resource "aws_iam_policy" "deny_destructive" {
  name        = "${var.ra}-technova-deny-destructive"
  description = "Nega explicitamente operacoes destrutivas"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "DenyDestructiveActions"
        Effect = "Deny"

        Action = [
          "s3:Delete*",
          "ec2:Terminate*",
          "ec2:Delete*"
        ]

        Resource = "*"
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
# Attach Policies aos Groups
# ========================================

resource "aws_iam_group_policy_attachment" "developers_s3_read" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.s3_read.arn
}

resource "aws_iam_group_policy_attachment" "developers_deny_destructive" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.deny_destructive.arn
}

resource "aws_iam_group_policy_attachment" "platform_ec2_s3" {
  group      = aws_iam_group.platform_eng.name
  policy_arn = aws_iam_policy.ec2_s3_full.arn
}