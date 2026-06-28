# Security Group para o ALB (Público) - Requisicoes externas > ALB
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Security Group para o ALB (Publico)"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Permite acesso externo via HTTP"
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

# Security Group para o cluster ECS (Privado) - Requisicoes ALB > ECS Tasks
resource "aws_security_group" "ecs_tasks_sg" {
  name        = "${var.project_name}-ecs-tasks-sg"
  description = "Permite trafego vindo do ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Permite trafego vindo do ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  tags = {
    Name = "${var.project_name}-ecs-tasks-sg"
  }
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

#Regra de entrada para o RDS
resource "aws_security_group_rule" "rds_ingress" {
  description              = "Permite conexao do ECS no Postgres"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_tasks_sg.id
  security_group_id        = aws_security_group.rds_sg.id
}

