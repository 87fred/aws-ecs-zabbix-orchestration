# =============================================================
# SECURITY GROUPS E REGRAS DE FIREWALL (44 RECURSOS)
# =============================================================

# Security Group para o ALB (Público) - Requisicoes externas > ALB
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Security Group para o ALB (Publico)"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Permite acesso externo via HTTP para o Zabbix"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# trivy:ignore:AWS-0104
resource "aws_security_group_rule" "alb_egress" {
  description       = "Permite que o ALB acesse qualquer recurso externo"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}

# Regra que permite tráfego externo para o Grafana na porta 3000
resource "aws_security_group_rule" "alb_grafana_ingress" {
  description       = "Permite acesso externo via HTTP para o Grafana"
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}

# Security Group para o cluster ECS (Privado) - Requisicoes ALB > ECS Tasks
resource "aws_security_group" "ecs_tasks_sg" {
  name        = "${var.project_name}-ecs-tasks-sg"
  description = "Permite trafego vindo do ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Permite trafego vindo do ALB para o Zabbix"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  tags = {
    Name = "${var.project_name}-ecs-tasks-sg"
  }
}

# Regra que permite tráfego do ALB para o Grafana internamente na porta 3000
resource "aws_security_group_rule" "ecs_grafana_ingress" {
  description              = "Permite trafego do ALB para o Grafana"
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id        = aws_security_group.ecs_tasks_sg.id
}

# trivy:ignore:AWS-0104
resource "aws_security_group_rule" "ecs_egress" {
  description       = "Permite saida para download de imagens e pacotes"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_tasks_sg.id
}

# Security Group para o Banco de Dados RDS
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Acesso ao banco de dados pelo ECS Tasks"
  vpc_id      = aws_vpc.main.id

  tags = {
    name = "${var.project_name}-rds-sg"
  }
}

# Regra de entrada para o RDS
resource "aws_security_group_rule" "rds_ingress" {
  description              = "Permite conexao do ECS no Postgres"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_tasks_sg.id
  security_group_id        = aws_security_group.rds_sg.id
}

# Security Group dedicado para os VPC Endpoints
resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "${var.project_name}-vpc-endpoint-sg"
  description = "Security Group para controlar o acesso aos VPC Endpoints"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-vpc-endpoint-sg"
  }
}

# Regra que permite tráfego de entrada na porta 443 vindo exclusivamente do ECS
resource "aws_security_group_rule" "vpc_endpoints_ingress" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vpc_endpoint_sg.id
  source_security_group_id = aws_security_group.ecs_tasks_sg.id
  description              = "Permite conexao HTTPS vinda do ECS Tasks"
}

# Regra separada para permitir que os Endpoints respondam de volta para as Tarefas ECS
resource "aws_security_group_rule" "vpc_endpoints_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.vpc_endpoint_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Permite que os Endpoints respondam as requisicoes internas"
}

# Regra separada para garantir o tráfego de saída do Banco de Dados (Segurança estrita)
resource "aws_security_group_rule" "rds_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.rds_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Permite respostas de conexao controladas do RDS"
}