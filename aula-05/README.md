# Aula 05 — RDS e Remote State (TechNova)

**Aluno:** Matheus Gabriel Correa Braga Viana | **RA:** 6325053

## Estrutura

- `aula-05-backend/` — Bootstrap: bucket S3 (versionado, criptografado, sem acesso público) + tabela DynamoDB para lock do state.
- `aula-05-rds/` — Projeto principal: VPC (2 AZs), EC2 (subnet pública, cliente psql), RDS PostgreSQL (subnets privadas), usando o backend S3 criado acima.

## Decisão técnica

O bucket S3 do backend é criado via **AWS CLI** (não via `aws_s3_bucket` do Terraform) porque a política do AWS Academy Learner Lab bloqueia a chamada `s3:GetBucketObjectLockConfiguration` que o provider tenta fazer ao gerenciar esse recurso diretamente (mesmo problema documentado na Aula 06). O Terraform gerencia apenas a configuração do bucket (versionamento, criptografia, bloqueio de acesso público) e a tabela DynamoDB.

A criptografia usada é SSE-S3 (AES256) em vez de SSE-KMS, para evitar depender da criação de uma KMS key (potencialmente restrita no Learner Lab) — suficiente para os requisitos do lab.

## Como usar

Veja o passo a passo completo na conversa / comandos fornecidos.
