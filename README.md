# 🚀 AWS ECS Zabbix & Grafana Orchestration

Projeto de **Infrastructure as Code (IaC)** utilizando **Terraform** para provisionar uma infraestrutura altamente segura, escalável, modular e baseada em **Amazon ECS Fargate**, orquestrando os serviços do **Zabbix** e **Grafana** na AWS.

O projeto foi desenvolvido aplicando conceitos avançados de **Cloud Architecture**, **DevSecOps**, segurança de credenciais e boas práticas de infraestrutura em produção.

---

# 🎯 Objetivo

Construir e demonstrar uma infraestrutura AWS robusta utilizando Terraform, seguindo as melhores práticas de mercado:

* **Infrastructure as Code (IaC):** Versionamento, reprodutibilidade e facilidade de manutenção.
* **DevSecOps & Segurança:** Injeção de credenciais de forma mascarada, criptografia e isolamento de rede.
* **Serverless & Escalabilidade:** Orquestração de containers sem gerenciamento de instâncias EC2.
* **Alta Disponibilidade:** Distribuição dos recursos em múltiplas Availability Zones (AZs).

---

# 📦 Recursos Implementados

## 🌐 Rede e Segurança (`network.tf` / `security.tf`)

* Amazon VPC
* Subnets Públicas (AZ A e AZ B)
* Subnets Privadas (AZ A e AZ B)
* Internet Gateway
* Route Tables
* Security Groups restritivos

### Características

* Segmentação completa da infraestrutura.
* Banco de dados isolado em subnets privadas.
* Application Load Balancer exposto apenas para os serviços necessários.
* Comunicação permitida apenas entre ALB → ECS → RDS.

---

## 🗄️ Camada de Dados (`rds.tf`)

* Amazon RDS PostgreSQL 15.7
* AWS Secrets Manager

### Características

* Banco PostgreSQL executando em subnets privadas.
* Credenciais armazenadas de forma segura no Secrets Manager.
* Nenhuma senha armazenada no código Terraform.

---

## ⚙️ Orquestração de Containers (`ecs.tf`)

* Amazon ECS Cluster
* ECS Task Definition
* ECS Service
* Amazon ECR
* AWS Fargate
* FARGATE_SPOT
* Amazon CloudWatch Logs

### Características

* Containers executados em infraestrutura serverless.
* Task Definitions independentes para Zabbix e Grafana.
* Utilização do bloco `secrets` do ECS para ocultar credenciais.
* Logs centralizados no CloudWatch.

---

## 🌍 Balanceamento de Carga (`alb.tf`)

* Application Load Balancer (ALB)
* Listeners
* Target Groups

### Portas

| Serviço | Porta |
| ------- | ----: |
| Zabbix  |    80 |
| Grafana |  3000 |

---

## 📊 Outputs (`outputs.tf`)

Ao término do provisionamento são exibidas automaticamente:

* URL do Zabbix
* URL do Grafana

---

# 📂 Estrutura do Projeto

```text
.
├── alb.tf
├── dev.tfvars
├── ecs.tf
├── network.tf
├── outputs.tf
├── providers.tf
├── rds.tf
├── security.tf
└── variables.tf
```

## Arquivos

| Arquivo        | Responsabilidade                                             |
| -------------- | ------------------------------------------------------------ |
| `alb.tf`       | Application Load Balancer, Listeners e Target Groups         |
| `dev.tfvars`   | Variáveis do ambiente de desenvolvimento                     |
| `ecs.tf`       | ECS Cluster, Task Definitions, ECS Services, CloudWatch Logs |
| `network.tf`   | VPC, Subnets, Route Tables e Internet Gateway                |
| `outputs.tf`   | URLs públicas após o deploy                                  |
| `providers.tf` | Providers AWS e configuração de Tags                         |
| `rds.tf`       | Amazon RDS PostgreSQL e Secrets Manager                      |
| `security.tf`  | Security Groups                                              |
| `variables.tf` | Declaração das variáveis                                     |

---

# 🔒 Segurança (Padrão Produção)

A arquitetura foi desenvolvida seguindo os princípios de **Least Privilege** e **Zero Hardcoded Values**.

## ✅ Mascaramento de Credenciais

Ao invés de utilizar variáveis em `environment`, as credenciais são carregadas através do bloco:

```hcl
secrets {
  name      = "POSTGRES_PASSWORD"
  valueFrom = aws_secretsmanager_secret.rds.arn
}
```

Dessa forma:

* nenhuma senha aparece no Terraform;
* nenhuma senha aparece no Console da AWS;
* as credenciais são injetadas diretamente na memória do container.

---

## ✅ Banco de Dados Privado

O Amazon RDS:

* não possui IP público;
* aceita conexões apenas do Security Group do ECS;
* permanece inacessível pela Internet.

---

## ✅ Resource Tagging

Todos os recursos recebem tags automaticamente utilizando o Terraform Workspace.

Exemplo:

```text
Environment = dev
ManagedBy   = Terraform
Project     = aws-ecs-zabbix-orchestration
```

---

# ⚙️ Pré-requisitos

Antes da execução é necessário possuir:

* Terraform >= 1.5
* AWS CLI configurada
* Credenciais AWS válidas
* Um Secret previamente criado no AWS Secrets Manager

Nome do Secret:

```text
aws-ecs-zabbix-orchestration-rds-secret-v1
```

Formato esperado:

```json
{
  "username": "seu_usuario",
  "password": "sua_senha_segura"
}
```

---

# 🚀 Como Executar

## Inicializar o Terraform

```bash
terraform init
```

---

## Criar ou selecionar o Workspace

```bash
terraform workspace new dev || terraform workspace select dev
```

---

## Validar a configuração

```bash
terraform validate
```

---

## Visualizar o plano

```bash
terraform plan -var-file="dev.tfvars"
```

---

## Provisionar a infraestrutura

```bash
terraform apply -var-file="dev.tfvars"
```

Ao final serão exibidos:

```text
Outputs:

grafana_url =
http://aws-ecs-zabbix-orchestration-alb-xxxxx.us-east-1.elb.amazonaws.com:3000

zabbix_url =
http://aws-ecs-zabbix-orchestration-alb-xxxxx.us-east-1.elb.amazonaws.com
```

---

## Destruir toda a infraestrutura

```bash
terraform destroy -var-file="dev.tfvars"
```

---

# 🏗️ Arquitetura

```text
               Internet
                    │
                    │
          Application Load Balancer
                    │
          ┌─────────┴─────────┐
          │                   │
      ECS Service        ECS Service
       (Zabbix)          (Grafana)
          │                   │
          └─────────┬─────────┘
                    │
            Amazon ECS Cluster
               (AWS Fargate)
                    │
          AWS Secrets Manager
                    │
             Amazon RDS PostgreSQL
             (Subnets Privadas)
```

---

# 🛠️ Tecnologias Utilizadas

* Terraform
* AWS
* Amazon ECS
* AWS Fargate
* Amazon ECR
* Amazon RDS PostgreSQL
* Amazon VPC
* Application Load Balancer
* AWS Secrets Manager
* Amazon CloudWatch
* IAM
* Security Groups
* Zabbix
* Grafana

---

# 📚 Conceitos Demonstrados

* Infrastructure as Code (IaC)
* Cloud Architecture
* DevSecOps
* Least Privilege
* Secrets Management
* Container Orchestration
* Alta Disponibilidade
* Observabilidade
* Infraestrutura Serverless
* Terraform Workspaces
* Resource Tagging
* Networking AWS

---

# 👨‍💻 Autor

**Frederico Almeida**

**Network & Cloud Analyst | DevOps | AWS | Terraform | Linux**

