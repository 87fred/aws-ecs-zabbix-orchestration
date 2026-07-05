# variables.tf

variable "aws_region" {
  type        = string
  description = "Regiao da AWS onde a infraestrutura sera provisionada"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Nome base do projeto para composicao de tags e recursos"
}

variable "vpc_cidr" {
  type        = string
  description = "Bloco de IP (CIDR) da VPC principal"
}

variable "public_subnet_a_cidr" {
  type        = string
  description = "Bloco de IP (CIDR) da Subnet Publica A"
}

variable "public_subnet_b_cidr" {
  type        = string
  description = "Bloco de IP (CIDR) da Subnet Publica B"
}

variable "db_parameter_group_name" {
  description = "Nome do grupo de parametros do RDS"
  type        = string
  default     = "default.postgres15"
}

variable "rds_db_name" {
  description = "Nome do banco de dados do RDS - Zabbix"
  type        = string
}

variable "rds_username" {
  description = "Nome do usuario do banco de dados do RDS - Zabbix"
  type        = string
}

variable "private_subnet_a_cidr" {
  type        = string
  description = "Bloco de IP (CIDR) da Subnet Privada A"
}

variable "private_subnet_b_cidr" {
  type        = string
  description = "Bloco de IP (CIDR) da Subnet Privada B"
}
variable "app_timezone" {
  description = "Fuso horario para a aplicacao PHP/Zabbix"
  type        = string
  default     = "America/Sao_Paulo"
}

variable "zabbix_server_image" {
  type        = string
  description = "Imagem docker para o Zabbix Server"
  default     = "ubuntu/zabbix-server-postgresql:6.4-latest"
}

variable "zabbix_web_image" {
  type        = string
  description = "Imagem docker para o Zabbix Web Interface"
  default     = "zabbix/zabbix-web-nginx-pgsql:6.4-ubuntu-latest"
}

variable "grafana_image" {
  type        = string
  description = "Imagem docker para o Grafana"
  default     = "grafana/grafana:latest"
}