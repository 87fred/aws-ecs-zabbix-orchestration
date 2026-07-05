# =============================================================
# 1. SECURITY GROUP DO ALB 
# =============================================================
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Security Group para o ALB (Publico)"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Permite acesso externo via HTTP - Zabbix"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Permite acesso externo via HTTP - Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# trivy:ignore:AWS-0104
resource "aws_security_group_rule" "alb_egress" {
  description       = "Permite que o ALB envie trafego para a rede"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}

# =============================================================
# 2. SECURITY GROUP DAS ECS TASKS 
# =============================================================
resource "aws_security_group" "ecs_tasks_sg" {
  name        = "${var.project_name}-ecs-tasks-sg"
  description = "Permite trafego vindo exclusivamente do ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-ecs-tasks-sg"
  }
}

# Regra Isolada: Entrada Zabbix vinda do ALB
resource "aws_security_group_rule" "ecs_ingress_zabbix" {
  description              = "Permite trafego do ALB para o Zabbix"
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id        = aws_security_group.ecs_tasks_sg.id
}

# Regra Isolada: Entrada Grafana vinda do ALB
resource "aws_security_group_rule" "ecs_ingress_grafana" {
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
  description       = "Permite saida para internet (download de imagens/updates)"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_tasks_sg.id
}

resource "aws_security_group_rule" "ecs_ingress_zabbix_server" {
  description              = "Permite trafego na porta nativa do Zabbix Server"
  type                     = "ingress"
  from_port                = 10051
  to_port                  = 10051
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_tasks_sg.id # O SG aponta para si mesmo
  security_group_id        = aws_security_group.ecs_tasks_sg.id
}

# =============================================================
# 3. SECURITY GROUP DO BANCO DE DADOS RDS 
# =============================================================
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Acesso ao banco de dados pelo ECS Tasks"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

# Regra Isolada: Entrada Postgres vinda dos Containers
resource "aws_security_group_rule" "rds_ingress" {
  description              = "Permite conexao das ECS Tasks no Postgres"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_tasks_sg.id
  security_group_id        = aws_security_group.rds_sg.id
}
resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "${var.project_name}-vpc-endpoints-sg"
  description = "SG paa as interfaces do PrivateLink (ECR/LOGS)"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-vpc-endpoints-sg"
  }
}
#Regra isolada - permite entrada HTTPS vinda apenas das Tasks do ECS
resource "aws_security_group_rule" "vpc_endpoints_ingress" {
  description              = "permite conexao das ECS Tasks para os servicos AWS"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_tasks_sg.id
  security_group_id        = aws_security_group.vpc_endpoint_sg.id
}


