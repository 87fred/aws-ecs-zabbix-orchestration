# trivy:ignore:AWS-0104
# Security Group para o ALB (Público)
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Security Group para o ALB (Público)"
  vpc_id      = aws_vpc.main.id

  # Regras ingress: Permite acesso externo via HTTP
  ingress {
    description = "Permite acesso externo via HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regra egress: Permite que o ALB acesse qualquer recurso (Necessário para rotear tráfego para os containers)
  egress {
    description = "Permite que o ALB acesse qualquer recurso"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# OBS: Não foi adicionado a regra para HTTPS pois esse ambiente não terá certificado SSL por conta de ser um portfolio.
# trivy:ignore:AWS-0104
# Security Group para o cluster ECS (Privado)
resource "aws_security_group" "ecs_tasks_sg" {
  name        = "${var.project_name}-ecs-tasks-sg"
  description = "Permite tráfego vindo do ALB"
  vpc_id      = aws_vpc.main.id

  # Regra de Entrada: Tranca a porta do Zabbix (8080) para a internet
  # e abre APENAS para o Security Group do ALB criado acima
  ingress {
    description     = "Permite tráfego vindo do ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Regra de Saída: Permite que o container baixe imagens e atualize pacotes na internet
  egress {
    description      = "Permite saida total para comunicacao e download de imagens"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project_name}-ecs-tasks-sg"
  }
}