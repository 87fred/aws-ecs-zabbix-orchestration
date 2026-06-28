# 🚀 AWS ECS Zabbix Orchestration

Projeto de **Infrastructure as Code (IaC)** utilizando **Terraform** para provisionar uma infraestrutura segura, escalável e modular na AWS, servindo como base para uma futura implantação do **Zabbix** utilizando **Amazon ECS**.

O projeto está sendo desenvolvido de forma incremental, documentando toda a evolução da arquitetura e aplicando boas práticas de **Cloud Computing**, **DevSecOps** e **Infrastructure as Code**.

---

# 🎯 Objetivo

Construir uma infraestrutura AWS utilizando Terraform seguindo boas práticas de:

* Infrastructure as Code (IaC)
* Cloud Architecture
* DevSecOps
* Segurança
* Escalabilidade
* Alta disponibilidade

Toda a infraestrutura é provisionada através do Terraform, garantindo versionamento, reprodutibilidade e facilidade de manutenção.

---

# 📦 Recursos Implementados

## 🌐 Infraestrutura

* Amazon VPC
* Internet Gateway
* Public Subnets
* Private Subnets
* Route Tables
* Security Groups

---

## 🗄 Banco de Dados

* Amazon RDS PostgreSQL
* DB Subnet Group
* AWS Secrets Manager

---

## ⚙️ Organização

* Terraform Providers
* Variáveis reutilizáveis
* Ambientes utilizando `.tfvars`
* Resource Tagging

---

# 📂 Estrutura do Projeto

```text
.
├── providers.tf
├── variables.tf
├── network.tf
├── security.tf
├── rds.tf
├── dev.tfvars
└── README.md
```

| Arquivo        | Responsabilidade                                                            |
| -------------- | --------------------------------------------------------------------------- |
| `providers.tf` | Configuração dos providers e tags padrão                                    |
| `variables.tf` | Declaração das variáveis do projeto                                         |
| `network.tf`   | Provisionamento da infraestrutura de rede                                   |
| `security.tf`  | Configuração dos Security Groups                                            |
| `rds.tf`       | Provisionamento do Amazon RDS e leitura das credenciais via Secrets Manager |
| `dev.tfvars`   | Valores das variáveis para o ambiente de desenvolvimento                    |

---

# 🔒 Segurança

A arquitetura foi desenvolvida seguindo o princípio de **Least Privilege**, implementando:

* Banco de dados privado
* Security Groups específicos para cada camada
* Credenciais armazenadas no AWS Secrets Manager
* Separação entre Subnets Públicas e Privadas
* Resource Tagging para padronização dos recursos

---

# ⚙️ Pré-requisitos

Antes de executar o projeto, é necessário possuir:

* Terraform >= 1.5
* AWS CLI configurado
* Conta AWS
* Permissões para criação dos recursos

Também é necessário criar previamente um Secret no AWS Secrets Manager com o nome:

```text
aws-ecs-zabbix-orchestration-rds-secret-v1
```

Formato esperado:

```json
{
  "username": "admin",
  "password": "password"
}
```

---

# 🚀 Como executar

Inicializar o projeto:

```bash
terraform init
```

Validar a configuração:

```bash
terraform validate
```

Formatar os arquivos:

```bash
terraform fmt
```

Gerar o plano de execução:

```bash
terraform plan -var-file="dev.tfvars"
```

Provisionar a infraestrutura:

```bash
terraform apply -var-file="dev.tfvars"
```

Remover a infraestrutura:

```bash
terraform destroy -var-file="dev.tfvars"
```

---

# 📚 Boas Práticas Aplicadas

* Infrastructure as Code (IaC)
* Cloud Native
* DevSecOps
* Least Privilege
* Resource Tagging
* Organização por responsabilidade
* Reutilização de variáveis
* Ambientes separados por `.tfvars`
* Gerenciamento seguro de credenciais

---

# 🚀 Próximas Evoluções

O projeto continuará evoluindo com a implementação dos seguintes serviços:

## Containers

* Amazon Elastic Container Registry (ECR)
* Amazon ECS Cluster
* Amazon ECS Task Definition
* Amazon ECS Service

## Balanceamento de Carga

* Application Load Balancer (ALB)

## Observabilidade

* Amazon CloudWatch

---

# 🎯 Objetivo do Projeto

Este projeto faz parte do meu portfólio profissional e tem como objetivo demonstrar a construção de uma infraestrutura AWS moderna utilizando Terraform.

A proposta é evoluir continuamente a arquitetura, incorporando novos serviços e boas práticas utilizadas em ambientes de produção, documentando cada etapa da implementação.

---

# 👨‍💻 Autor

**Frederico Almeida**

Cloud Engineer | DevOps | AWS | Terraform | Linux

Projeto desenvolvido para fins de estudo, evolução técnica e composição de portfólio profissional.
