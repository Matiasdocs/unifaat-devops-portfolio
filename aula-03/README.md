# Aula 03 — Terraform + IAM | Matheus Gabriel Correa Braga Viana (6325053)

## Design da Estrutura IAM

A estrutura IAM da TechNova foi criada separando os usuários de acordo com suas responsabilidades. O grupo `6325053-technova-developers` representa os desenvolvedores que precisam principalmente consultar dados armazenados no S3. Já o grupo `6325053-technova-platform-eng` possui permissões adicionais para atividades relacionadas à infraestrutura, como visualizar, iniciar e parar instâncias EC2 e acessar dados no S3.

Foram criados três usuários. Juliana e Lucas pertencem ao grupo de developers. Rafael também pertence ao grupo de developers, mas faz parte do grupo platform-eng por precisar de permissões adicionais relacionadas à infraestrutura.

As policies foram criadas de forma personalizada para evitar permissões maiores do que o necessário. A policy `6325053-technova-s3-read` permite apenas listar buckets e ler objetos dos buckets `technova-*`. A policy `6325053-technova-ec2-s3-full` permite operações específicas em EC2 e acesso de leitura e escrita ao S3. Para iniciar ou parar instâncias EC2, é necessário que o recurso possua a tag `Project=TechNova`.

Também foi criada a policy `6325053-technova-deny-destructive`, que utiliza um Deny explícito para impedir operações destrutivas, como exclusão de recursos e término de instâncias.

## Princípio do Menor Privilégio

O princípio do menor privilégio significa fornecer para cada usuário ou serviço somente as permissões necessárias para realizar sua função.

Um exemplo utilizado neste projeto é o grupo developers. Em vez de fornecer acesso completo ao S3, os desenvolvedores recebem somente `s3:ListBucket` e `s3:GetObject`.

Outro exemplo está nas permissões de EC2 do grupo platform-eng. As ações de iniciar e parar instâncias possuem uma Condition que exige a tag `Project=TechNova`, evitando que essas permissões sejam utilizadas livremente em qualquer instância.

Se fosse utilizada a policy `AmazonS3FullAccess` no lugar da policy personalizada, os usuários receberiam várias permissões que não são necessárias para suas funções. Isso aumentaria o risco de alterações ou exclusões acidentais e iria contra o princípio do menor privilégio.

## Diagrama de Permissões

```text
Juliana ──┐
          ├──> Developers ──> S3 Read ──> technova-*
Lucas ────┤                 │
          │                 └──> Deny Destructive
Rafael ───┘
   │
   └──> Platform Engineering
             │
             └──> EC2 + S3
                   ├──> EC2 Describe
                   ├──> EC2 Start/Stop
                   │     somente Project=TechNova
                   └──> S3 Read/Write

EC2
 │
 ▼
Instance Profile
6325053-technova-ec2-profile
 │
 ▼
Service Role
6325053-technova-ec2-role
 │
 ▼
S3 Read/Write
technova-app-data-*
```

## Comandos Utilizados

```bash
terraform fmt
terraform init
terraform validate
terraform plan
terraform apply
terraform destroy
```

## Reflexão

A criação manual de usuários, grupos, roles e policies pelo Console AWS pode funcionar em ambientes pequenos, mas aumenta a possibilidade de erros e dificulta saber exatamente quais alterações foram realizadas ao longo do tempo.

Com Terraform, a infraestrutura e as permissões ficam descritas em código. Dessa forma, é possível revisar as configurações antes de aplicá-las, utilizar controle de versão com Git e manter um histórico das mudanças.

Para uma equipe, considero a abordagem com Terraform mais segura e auditável porque as alterações podem ser revisadas antes da aplicação e o código serve como documentação da infraestrutura. Além disso, o uso de policies personalizadas facilita a aplicação do princípio do menor privilégio.