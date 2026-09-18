# Infraestrutura TechNova — Aula 04

**Aluno:** Matheus Gabriel Correa Braga Viana
**RA:** 6325053
**Disciplina:** DevOps — UniFAAT 2026-2

## Diagrama da Arquitetura

```
                              Internet
                                 |
                          +------+------+
                          |  Internet   |
                          |  Gateway    |
                          +------+------+
                                 |
                    +------------+------------+
                    |   Route Table (publica)  |
                    |   0.0.0.0/0 -> IGW        |
                    +------------+------------+
                                 |
          +----------------------+----------------------+
          |                    VPC (10.0.0.0/16)         |
          |                                               |
          |  AZ: us-east-1a          AZ: us-east-1b       |
          |  +------------------+    +------------------+ |
          |  | Subnet Publica 1 |    | Subnet Publica 2 | |
          |  |  10.0.1.0/24     |    |  10.0.3.0/24     | |
          |  |                  |    |                  | |
          |  |  +------------+  |    |                  | |
          |  |  |  EC2 API   |  |    |                  | |
          |  |  |  t2.micro  |  |    |                  | |
          |  |  |  :22 :3000 |  |    |                  | |
          |  |  +------------+  |    |                  | |
          |  +------------------+    +------------------+ |
          |                                               |
          |  +------------------+    +------------------+ |
          |  | Subnet Privada 1 |    | Subnet Privada 2 | |
          |  |  10.0.2.0/24     |    |  10.0.4.0/24     | |
          |  |  (reservada para |    |  (reservada para | |
          |  |   RDS futuro)    |    |   RDS futuro)    | |
          |  +------------------+    +------------------+ |
          +-----------------------------------------------+

  Security Groups:
  - api-sg: 22 (SSH) e 3000 (API) de 0.0.0.0/0, egress liberado
  - db-sg:  5432 (PostgreSQL) apenas de 10.0.0.0/16 (interno da VPC)
```

## Como usar

### Pré-requisitos

- AWS CLI configurado com credenciais do AWS Academy Learner Lab
- Terraform >= 1.0
- Uma chave SSH gerada localmente:
  ```bash
  ssh-keygen -t rsa -b 4096 -f ~/.ssh/technova-key -N ""
  chmod 400 ~/.ssh/technova-key
  ```

### Executar

```bash
cd aula-04
terraform init
terraform validate
terraform plan
terraform apply
```

### Testar

```bash
export API_IP=$(terraform output -raw ec2_public_ip)
curl http://$API_IP:3000
curl http://$API_IP:3000/health
curl http://$API_IP:3000/orders
ssh -i ~/.ssh/technova-key ec2-user@$API_IP
```

### Destruir

```bash
terraform destroy
```

> ⚠️ **Sempre destrua os recursos após capturar as evidências**, para não consumir os créditos do Learner Lab.

## Decisões técnicas

- **Multi-AZ (2 zonas):** subnets distribuídas em `us-east-1a` e `us-east-1b`, preparando o terreno para um Load Balancer ou RDS Multi-AZ no futuro.
- **Separação público/privado:** a API fica na subnet pública (precisa ser alcançável pela internet); as subnets privadas ficam reservadas para recursos que nunca devem ser expostos diretamente (ex: banco de dados).
- **`LabInstanceProfile` em vez de criar uma IAM Role:** o AWS Academy Learner Lab bloqueia `aws_iam_role`/`aws_iam_instance_profile` (documentado no laboratório da aula). Usamos o instance profile pré-existente `LabInstanceProfile` (já com a `LabRole`, que inclui S3ReadOnlyAccess), evitando o erro `AccessDenied` em `iam:CreateRole`.
- **AMI via data source:** evita fixar um ID que fica desatualizado com o tempo.
- **User Data em arquivo separado:** mais fácil de ler, editar e versionar do que inline no `main.tf`.

## Recursos criados

| Recurso | Nome/Tipo | Função |
|---|---|---|
| `aws_vpc.main` | `technova-vpc` | Rede isolada da TechNova (10.0.0.0/16) |
| `aws_subnet.public[0..1]` | `technova-public-subnet-1/2` | Subnets públicas, 2 AZs |
| `aws_subnet.private[0..1]` | `technova-private-subnet-1/2` | Subnets privadas, 2 AZs (reservadas p/ RDS) |
| `aws_internet_gateway.main` | `technova-igw` | Conecta a VPC à internet |
| `aws_route_table.public` | `technova-public-rt` | Rota 0.0.0.0/0 → IGW |
| `aws_route_table_association.public[0..1]` | — | Associa a RT pública às 2 subnets públicas |
| `aws_security_group.api` | `technova-api-sg` | Libera SSH (22) e API (3000) |
| `aws_security_group.db` | `technova-db-sg` | Libera PostgreSQL (5432) só da VPC |
| `aws_key_pair.main` | `technova-key` | Registra a chave pública SSH |
| `aws_instance.api` | `technova-ec2-api` | EC2 t2.micro rodando a API TechNova |
| `data.aws_ami.amazon_linux` | — | Busca a AMI mais recente do Amazon Linux 2023 |
