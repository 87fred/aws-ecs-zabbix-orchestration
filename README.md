# 🚀 AWS ECS Zabbix & Grafana Orchestration

### 📌 Visão Geral
Infraestrutura *production-like* de observabilidade na AWS utilizando **Terraform (IaC)** para provisionar um ambiente altamente escalável, tolerante a falhas e seguro contendo:

* **Zabbix** (Monitoramento robusto e coleta de dados)
* **Grafana** (Visualização rica e dashboards analíticos)
* **AWS ECS Fargate** (*Serverless containers orchestration*)
* **Amazon RDS PostgreSQL** (Persistência de dados gerenciada)
* **AWS Secrets Manager** (Gestão e injeção segura de credenciais)

O projeto simula com precisão uma arquitetura real de produção voltada para engenharia de observabilidade moderna baseada em containers.

---

### 🎯 Objetivo
Projetar e demonstrar uma infraestrutura cloud completa com foco em pilares de excelência técnica:

* **Infraestrutura como Código (IaC):** Automação total, reprodutibilidade e versionamento de ambiente.
* **Segurança por padrão (DevSecOps):** Mitigação de vulnerabilidades e exposição zero de dados sensíveis.
* **Arquitetura Multi-AZ:** Resiliência e alta disponibilidade distribuída em diferentes zonas.
* **Escalabilidade Serverless:** Computação elástica com ECS Fargate sem gerenciar instâncias de servidores.
* **Observabilidade Centralizada:** Coleta de logs agregados nativamente.

---

### 🧠 Decisões Arquiteturais

* **ECS Fargate:** Elimina a complexidade de gestão, patches e escalabilidade de instâncias EC2 tradicionais.
* **RDS em Subnets Privadas:** Isolamento de rede absoluto da camada de banco de dados, sem qualquer exposição à internet pública.
* **AWS PrivateLink (VPC Endpoints):** Comunicação do ECS para downloads de imagens de repositórios e envio de logs de forma 100% interna na rede AWS, dispensando custos com NAT Gateways.
* **Secrets Manager via IAM Data Fetching:** Zero credenciais codificadas (*hardcoded*) no código, injetadas de forma efêmera na memória volátil dos containers.
* **ALB Inteligente:** Entrada pública única e centralizada chaveando tráfego por portas e regras dinâmicas de destino (*Target Groups*).
* **IAM Least Privilege:** Aplicação rígida do princípio de menor privilégio para regras de execução das tarefas.

---

### 🏗️ Arquitetura Lógica do Fluxo

```text
               [ Internet Pública ]
                        │
                Portas 80 / 3000
                        ▼
            Application Load Balancer
           (Subnets Públicas AZ A/B)
                        │
      ┌─────────────────┴─────────────────┐
Porta 8080 (Zabbix Web)            Porta 3000 (Grafana)
      ▼                                   ▼
 [ ECS Service ]                     [ ECS Service ]
Task: Zabbix Server/Web               Task: Grafana
      │                                   │
      └─────────────────┬─────────────────┘
                        ▼
              [ VPC Endpoints SG ]
            Porta 443 (PrivateLink)
                        ▼
         ┌──────────────┼──────────────┐
         ▼              ▼              ▼
     [ECR API]      [ECR DKR]    [CloudWatch]

🔐 Segurança (DevSecOps)

    Banco de dados inacessível externamente e sem associação de IP público.

    Injeção dinâmica de segredos no boot da Task através do parâmetro secrets do ECS.

    Comunicação restrita horizontalmente através de regras de Security Groups isoladas (aws_security_group_rule).

    Segregação física e lógica de redes através de subnets públicas e privadas bem definidas.

⚙️ Stack Tecnológica

    Terraform

    AWS ECS Fargate & Fargate Spot

    Amazon ECR (Elastic Container Registry)

    Amazon RDS PostgreSQL 15.7

    Amazon VPC & AWS PrivateLink (VPC Endpoints)

    Application Load Balancer (ALB)

    AWS Secrets Manager

    Amazon CloudWatch Logs

    AWS IAM (Identity and Access Management)

    Zabbix Application Suite

    Grafana Dashboards

📦 Recursos Provisionados

    1x AWS VPC com DNS Hostnames ativado.

    4x Subnets (2 públicas para o ALB e 2 privadas para computação/banco) distribuídas in Multi-AZ.

    3x VPC Endpoints de Interface (ECR API, ECR DKR e Logs) para segurança interna.

    1x Amazon ECS Cluster com painel Container Insights ativo no CloudWatch.

    2x ECS Task Definitions segregadas (Zabbix Server/Web em Pod multicontainer e Grafana autônomo).

    2x ECS Services gerenciando ciclo de vida e checagem de saúde contínua das tarefas.

    1x Application Load Balancer público munido de Listeners nas portas 80 e 3000.

    2x Target Groups do tipo ip orquestrando o roteamento privado.

    1x Instância de Banco de Dados RDS PostgreSQL acoplada a um DB Subnet Group privado.

    4x Security Groups customizados atuando como firewalls estritos de rede.

📁 Estrutura do Projeto
Plaintext

.
├── alb.tf         # Configuração do Load Balancer, Listeners e Target Groups
├── ecs.tf         # Definição do Cluster, Task Definitions, Services e Logs
├── network.tf     # Construção da VPC, Subnets, Tabelas de Roteamento e Endpoints
├── rds.tf         # Provisionamento do PostgreSQL e integração com Secrets Manager
├── security.tf    # Definição fina de Security Groups e regras de Ingress/Egress
├── outputs.tf     # Exposição estruturada das URLs públicas pós-deploy
├── providers.tf   # Definições de provedores e injeção automática de tags padrão
├── variables.tf   # Declaração e tipagem rigorosa das variáveis de entrada
└── dev.tfvars     # Atribuição de valores específicos para o ambiente de Desenvolvimento

🚀 Como Executar
1. Inicializar o ambiente do Terraform
Bash

terraform init

2. Criar ou selecionar o Workspace dedicado
Bash

terraform workspace select dev || terraform workspace new dev

3. Validar estaticamente a sintaxe dos arquivos
Bash

terraform validate

4. Visualizar o plano de execução e alterações planejadas
Bash

terraform plan -var-file="dev.tfvars"

5. Executar o deploy automatizado na AWS
Bash

terraform apply -var-file="dev.tfvars"

6. Destruir o ambiente (Limpeza pós-uso)
Bash

terraform destroy -var-file="dev.tfvars"

🌐 Mapeamento de Outputs e URLs

Ao término do terraform apply, o console exibirá de forma estruturada as seguintes rotas públicas para acesso imediato no navegador:

    Zabbix Web interface: http://<alb-dns-name> (Porta padrão 80 HTTP)

    Grafana Dashboards: http://<alb-dns-name>:3000 (Porta 3000 HTTP)

🔥 Destaques Técnicos

    Arquitetura Resiliente Multi-AZ: Tolerância automática a falhas a nível de datacenter AWS.

    Mapeamento de Tráfego Interno Avançado: O ALB recebe requisições na porta 80 e as encaminha de forma transparente para as Tasks na porta 8080 nativa do container Zabbix Web Nginx.

    Estratégias de Custos Inteligentes: Uso flexível de Fargate Spot para computação otimizada em ambientes de não-produção.

    Infraestrutura 100% Reprodutível: Todo o ecossistema pode ser recriado do zero em minutos com apenas um comando.

👨‍💻 Autor

Frederico Almeida - Cloud & DevOps Engineer | AWS | Terraform | Linux