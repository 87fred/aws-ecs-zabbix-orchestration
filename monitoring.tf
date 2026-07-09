resource "aws_cloudwatch_dashboard" "main_dashboard" {
  dashboard_name = "${var.project_name}-sre-metrics"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric", x = 0, y = 0, width = 12, height = 5
        properties = {
          title  = "ECS: Consumo de CPU e Memória - Zabbix"
          period = 300, stat = "Average", region = var.aws_region
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", "${var.project_name}-zabbix-service", "ClusterName", "${var.project_name}-ecs-cluster-zabbix", { "label" = "CPU (%)", "color" = "#1f77b4" }],
            [".", "MemoryUtilization", ".", ".", ".", ".", { "label" = "Memória (%)", "color" = "#aec7e8" }]
          ]
        }
      },
      {
        type = "metric", x = 12, y = 0, width = 12, height = 5
        properties = {
          title  = "ECS: Consumo de CPU e Memória - Grafana"
          period = 300, stat = "Average", region = var.aws_region
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", "${var.project_name}-grafana-service", "ClusterName", "${var.project_name}-ecs-cluster-zabbix", { "label" = "CPU (%)", "color" = "#ff7f0e" }],
            [".", "MemoryUtilization", ".", ".", ".", ".", { "label" = "Memória (%)", "color" = "#ffbb78" }]
          ]
        }
      },
      {
        type = "metric", x = 0, y = 5, width = 12, height = 5
        properties = {
          title  = "ALB: Tráfego e Erros HTTP"
          period = 60, stat = "Sum", region = var.aws_region
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.alb.arn_suffix, { "label" = "Requisições (Total)", "color" = "#2ca02c" }],
            [".", "HTTPCode_Target_5XX_Count", ".", ".", { "label" = "Falhas HTTP 5XX", "color" = "#d62728" }]
          ]
        }
      },
      {
        type = "metric", x = 12, y = 5, width = 12, height = 5
        properties = {
          title  = "ALB: Latência de Resposta"
          period = 300, stat = "Average", region = var.aws_region
          # Esta configuração força o gráfico a mostrar 0 se não houver dados, removendo o erro
          treatMissingData = "notBreaching"
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.alb.arn_suffix, { "label" = "Latência Média (s)", "color" = "#9467bd" }]
          ]
        }
      },
      {
        type = "metric", x = 0, y = 10, width = 24, height = 5
        properties = {
          title  = "RDS: Saúde do Banco de Dados"
          period = 300, stat = "Average", region = var.aws_region

          # Isso cria os nomes das réguas verticais esquerda e direita
          yAxis = {
            left  = { label = "Porcentagem (%)", min = 0, max = 100 },
            right = { label = "Quantidade (Conexões)", min = 0 }
          }

          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "${var.project_name}-rds-instance", { "label" = "CPU Banco (%)", "color" = "#d62728" }],
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "${var.project_name}-rds-instance", { "label" = "Conexões Ativas", "color" = "#2ca02c", "yAxis" = "right" }]
          ]
        }
      }
    ]
  })
}
#Alarmes
# 1. Alerta de CPU Alta no ECS (Zabbix ou Grafana)
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  for_each            = toset(["zabbix", "grafana"])
  alarm_name          = "${var.project_name}-ecs-${each.value}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alerta: CPU do ${each.value} acima de 80%"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = "${var.project_name}-ecs-cluster-zabbix"
    ServiceName = "${var.project_name}-${each.value}-service"
  }
}

# 2. Alerta de Erros 5XX no ALB (Indica falha crítica na aplicação)
resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "${var.project_name}-alb-5xx-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "5" # Mais de 5 erros em 1 minuto
  alarm_description   = "Alerta: Muitas falhas 5XX no ALB"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = aws_lb.alb.arn_suffix
  }
}

# 3. Alerta de Saúde do Banco de Dados (Conexões saturadas)
resource "aws_cloudwatch_metric_alarm" "rds_conn_high" {
  alarm_name          = "${var.project_name}-rds-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80" # Ajuste conforme o limite do seu RDS t3.micro
  alarm_description   = "Alerta: Conexões no RDS acima de 80"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = "${var.project_name}-rds-instance"
  }
}