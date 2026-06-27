# variables.tf

variable "aws_region" {
  type        = string
  description = "Regiao da AWS onde a infraestrutura sera provisionada"
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