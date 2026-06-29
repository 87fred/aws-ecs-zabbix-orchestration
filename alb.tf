#ALB - Público
resource "aws_lb" "alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = {
    Name = "${var.project_name}-alb"
  }
}

#Target Groups (Destinos nas subnets privadas)
resource "aws_lb_target_group" "zabbix" {
  name        = "${substr(var.project_name, 0, 20)}-tg-zabbix"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"
    port                = "8080"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.project_name}-tg-zabbix"
  }

}

resource "aws_lb_target_group" "grafana" {
  name        = "${substr(var.project_name, 0, 20)}-tg-grafana"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/api/health"
    port                = "3000"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.project_name}-tg-grafana"
  }

}

#Listener (Ouvintes - apontados para o ALB (aws_alb.alb))
#Ouvinte da porta 80 (Zabbix)
resource "aws_lb_listener" "zabbix_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.zabbix.arn
  }
}
#Ouvinte da porta 3000 (Grafana)
resource "aws_lb_listener" "grafana_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 3000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }
}