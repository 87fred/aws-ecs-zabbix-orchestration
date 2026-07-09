#Serviço de Notificação - AWS SNS
# sns.tf
resource "aws_sns_topic" "alerts" { # Mudei o nome aqui de sns_alerts para alerts
  name = "${var.project_name}-alerts-topic"
}

resource "aws_sns_topic_subscription" "email_alerts" {
  topic_arn = aws_sns_topic.alerts.arn 
  protocol  = "email"
  endpoint  = "email@email.com"
}