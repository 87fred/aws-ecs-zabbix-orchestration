# 🚀 AWS ECS Zabbix & Grafana Orchestration

### ⚙️ Stack Tecnológica (Continuação)
* Amazon CloudWatch Logs
* AWS IAM (Identity and Access Management)
* Zabbix Application Suite
* Grafana Dashboards

---

### 📦 Recursos Provisionados

* **1x AWS VPC** com DNS Hostnames ativado.
* **4x Subnets** (2 públicas para o ALB e 2 privadas para computação/banco) distribuídas em Multi-AZ.
* **3x VPC Endpoints** de Interface (ECR API, ECR DKR e Logs) para segurança interna.
* **1x Amazon ECS Cluster** com painel Container Insights ativo no CloudWatch.
* **2x ECS Task Definitions** segregadas (Zabbix Server/Web em Pod multicontainer e Grafana autônomo).
* **2x ECS Services** gerenciando ciclo de vida e checagem de saúde contínua das tarefas.
* **1x Application Load Balancer** público munido de Listeners nas portas 80 e 3000.
* **2x Target Groups** do tipo `ip` orquestrando o roteamento privado.
* **1x Instância de Banco de Dados RDS PostgreSQL** acoplada a um DB Subnet Group privado.
* **4x Security Groups** customizados atuando como firewalls estritos de rede.

---

### 📁 Estrutura do Projeto

```text
.
├── alb.tf
├── ecs.tf
├── endpoints.tf
├── network.tf
├── rds.tf
├── security.tf
├── outputs.tf
├── providers.tf
├── variables.tf
└── dev.tfvars
```

### 📋 Arquivos e Responsabilidades

| Arquivo | Responsabilidade |
| :--- | :--- |
| `alb.tf` | Application Load Balancer, Listeners e Target Groups. |
| `ecs.tf` | Definição do Cluster, Task Definitions, Services e Logs. |
| `endpoints.tf` | VPC Endpoints (Interface) dedicados para o PrivateLink do ECR (API/DKR) e CloudWatch Logs, removendo a dependência de internet ou NAT Gateways nas subnets privadas. |
| `network.tf` | Construção da VPC, Subnets Públicas/Privadas, Tabelas de Roteamento e Internet Gateway. |
| `rds.tf` | Provisionamento do PostgreSQL e integração com Secrets Manager. |
| `security.tf` | Definição fina de Security Groups e regras de Ingress/Egress. |
| `outputs.tf` | Exposição estruturada das URLs públicas pós-deploy. |
| `providers.tf` | Definições de provedores e injeção automática de tags padrão. |
| `variables.tf` | Declaração e tipagem rigorosa das variáveis de entrada. |
| `dev.tfvars` | Atribuição de valores específicos para o ambiente de Desenvolvimento. |

---

### 🚀 Como Executar

**1. Inicializar o ambiente do Terraform**
```bash
terraform init
```

**2. Criar ou selecionar o Workspace dedicado**
```bash
terraform workspace select dev || terraform workspace new dev
```

**3. Validar estaticamente a sintaxe dos arquivos**
```bash
terraform validate
```

**4. Visualizar o plano de execução e alterações planejadas**
```bash
terraform plan -var-file="dev.tfvars"
```

**5. Executar o deploy automatizado na AWS**
```bash
terraform apply -var-file="dev.tfvars"
```

**6. Destruir o ambiente (Limpeza pós-uso)**
```bash
terraform destroy -var-file="dev.tfvars"
```

---

### 🌐 Mapeamento de Outputs e URLs

Ao término do `terraform apply`, o console exibirá de forma estruturada as seguintes rotas públicas para acesso imediato no navegador:

* **Zabbix Web interface:** `http://<alb-dns-name>` (Porta padrão 80 HTTP)
* **Grafana Dashboards:** `http://<alb-dns-name>:3000` (Porta 3000 HTTP)

---

### 🔥 Destaques Técnicos

* **Arquitetura Resiliente Multi-AZ:** Tolerância automática a falhas a nível de datacenter AWS.
* **Mapeamento de Tráfego Interno Avançado:** O ALB recebe requisições na porta 80 e as encaminha de forma transparente para as Tasks na porta 8080 nativa do container Zabbix Web Nginx.
* **Estratégias de Custos Inteligentes:** Uso flexível de Fargate Spot para computação otimizada em ambientes de não-produção.
* **Infraestrutura 100% Reprodutível:** Todo o ecossistema pode ser recriado do zero em minutos com apenas um comando.

---

### 👨‍💻 Autor

**Frederico Almeida**  
*Cloud & DevOps Engineer | AWS | Terraform | Linux*