resource "aws_cloudwatch_dashboard" "main_dashboard" {
  dashboard_name = "${var.project_name}-sre-metrics"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric", x = 0, y = 0, width = 12, height = 5
        properties = {
          title = "ECS: Consumo de CPU e Memória - Zabbix"
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
          title = "ECS: Consumo de CPU e Memória - Grafana"
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
          title = "ALB: Tráfego e Erros HTTP"
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
          title = "ALB: Latência de Resposta"
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
          title = "RDS: Saúde do Banco de Dados"
          period = 300, stat = "Average", region = var.aws_region
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "${var.project_name}-rds-instance", { "label" = "CPU Banco (%)", "color" = "#d62728" }],
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "${var.project_name}-rds-instance", { "label" = "Conexões Ativas", "color" = "#2ca02c", "yAxis" = "right" }]
          ]
        }
      }
    ]
  })
}