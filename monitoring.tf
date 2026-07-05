# =============================================================
# RECURSO PRINCIPAL: DASHBOARD CENTRAL 
# =============================================================

resource "aws_cloudwatch_dashboard" "main_dashboard" {
  #Nome do Dashboard, que será exibido no console do CloudWatch  
  dashboard_name = "${var.project_name}-sre-metrics"

  #O Corpo do Dashboard é definido em JSON, que descreve os widgets e métricas a serem exibidas
  dashboard_body = jsonencode({
    widgets = [

      #Widget 1 - Métricas do Serviço ECS do Zabbix
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 5
       
        properties = {
          title  = "ECS: Saturação do Serviço Zabbix"
          period = 300
          stat   = "Average"
          region = var.aws_region

          #Matriz de métricas (Anmespace, MetricName, DimensionName, DimensionValue)
          metrics = [
            #Linha 1: Consumo de CPU do container Zabbix (Cor Azul)
            ["AWS/ECS", "CPUUtilization", "ServiceName", "${var.project_name}-zabbix-service", "ClusterName", "${var.project_name}-ecs-cluster-zabbix", { "label" = "CPU Zabbix (%)", "color" = "#1f77b4" }],
            # Linha 2: Consumo de Memória do container do Zabbix (O ponto "." herda o Namespace/Dimensões anteriores)
            [".", "MemoryUtilization", ".", ".", ".", ".", { "label" = "Memória Zabbix (%)", "color" = "#aec7e8" }]
          ]
        }
      },

      # -----------------------------------------------------------
      # WIDGET 2: MÉTRICAS DO SERVIÇO ECS DO GRAFANA
      # -----------------------------------------------------------
      {
        type   = "metric"
        x      = 12       # Começa no meio da tela (coluna 12) para ficar LADO A LADO com o Zabbix
        y      = 0        # Também fica na primeira linha do topo
        width  = 12       # Ocupa a outra metade da tela (12 colunas)
        height = 5

        properties = {
          title  = "ECS: Saturação do Serviço Grafana"
          period = 300
          stat   = "Average"
          region = var.aws_region

          metrics = [
            # Linha 1: Consumo de CPU do container do Grafana (Cor Laranja)
            ["AWS/ECS", "CPUUtilization", "ServiceName", "${var.project_name}-grafana-service", "ClusterName", "${var.project_name}-ecs-cluster-zabbix", { "label" = "CPU Grafana (%)", "color" = "#ff7f0e" }],
            # Linha 2: Consumo de Memória do container do Grafana
            [".", "MemoryUtilization", ".", ".", ".", ".", { "label" = "Memória Grafana (%)", "color" = "#ffbb78" }]
          ]
        }
      },

      # -----------------------------------------------------------
      # NOVO WIDGET 3: TRÁFEGO E TAXA DE ERROS DO ALB
      # -----------------------------------------------------------
      {
        type   = "metric"
        x      = 0        # Começa no canto esquerdo da tela
        y      = 5        # Fica na segunda linha do painel (abaixo do ECS)
        width  = 12       # Ocupa metade da tela (12 colunas)
        height = 5

        properties = {
          title  = "ALB: Tráfego e Erros nas Aplicações"
          period = 60      # Coleta dados a cada 1 minuto para monitoramento em tempo real de incidentes
          stat   = "Sum"     # Soma a quantidade total de requisições e erros no minuto
          region = var.aws_region

          metrics = [
            # Linha 1: Conta o volume total de requisições que chegam no balanceador (Cor Verde)
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.alb.arn_suffix, { "label" = "Volume de Requisições (Soma)", "color" = "#2ca02c" }],
            # Linha 2: Conta falhas internas HTTP 5XX causadas por problemas na aplicação ou indisponibilidade (Cor Vermelha)
            [".", "HTTPCode_Target_5XX_Count", ".", ".", { "label" = "Erros 5XX da Aplicação (Soma)", "color" = "#d62728" }]
          ]
        }
      },

      # -----------------------------------------------------------
      # NOVO WIDGET 4: LATÊNCIA DO USUÁRIO
      # -----------------------------------------------------------
      {
        type   = "metric"
        x      = 12       # Começa na metade da tela (coluna 12) para ficar emparelhado com o tráfego
        y      = 5        # Fica na segunda linha do painel
        width  = 12       # Ocupa a outra metade da tela
        height = 5

        properties = {
          title  = "ALB: Latência / Tempo de Resposta do Alvo"
          period = 60
          stat   = "Average" # Exibe a média do tempo de resposta
          region = var.aws_region

          metrics = [
            # Linha 1: Tempo em segundos que a aplicação leva para responder o balanceador (Cor Roxa)
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.alb.arn_suffix, { "label" = "Tempo de Resposta Médio (Segundos)", "color" = "#9467bd" }]
          ]
        }
      },

      # -----------------------------------------------------------
      # WIDGET 5: SAÚDE E SATURAÇÃO DO BANCO DE DADOS RDS (POSTGRES)
      # -----------------------------------------------------------
      {
        type   = "metric"
        x      = 0        # Começa no canto esquerdo da tela
        y      = 10       # Fica na TERCEIRA LINHA da tela (abaixo dos gráficos do ALB)
        width  = 24       # Ocupa a tela inteira (24 colunas de largura) para dar destaque ao banco
        height = 5

        properties = {
          title  = "RDS: Saúde do Banco de Dados"
          period = 300
          stat   = "Average"
          region = var.aws_region

          metrics = [
            # Linha 1: Consumo de CPU da máquina do RDS (Cor Vermelha no eixo Y esquerdo)
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "${var.project_name}-rds-instance", { "label" = "CPU RDS (%)", "color" = "#d62728" }],
            # Linha 2: Quantidade de conexões ativas abertas (Cor Verde no eixo Y direito - "yAxis" = "right")
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "${var.project_name}-rds-instance", { "label" = "Conexões Ativas (Count)", "color" = "#2ca02c", "yAxis" = "right" }]
          ]
        }
      }

    ]
  })
}

# -----------------------------------------------------------
# RECURSO ADICIONAL SRE: ALARME AUTOMÁTICO DE SEGURANÇA
# -----------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "rds_high_cpu" {
  alarm_name          = "${var.project_name}-rds-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2                                # Dispara apenas após falhar por 2 períodos consecutivos (evita falsos alertas)
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300                              # Intervalo de validação de 5 em 5 minutos
  statistic           = "Average"
  threshold           = 90                               # Limite de tolerância de 90% de uso de CPU
  alarm_description   = "Alarme: Alerta crítico se o banco de dados PostgreSQL ultrapassar 90% de CPU."

  dimensions = {
    DBInstanceIdentifier = "${var.project_name}-rds-instance" # Aplica o alarme diretamente ao banco do projeto
  }

#Conecta o alarme ao Canal (topic) do SNS para envio de notificações que foi criado no arquivo sns.tf
 alarm_actions = [aws_sns_topic.sns_alerts.arn]

}

