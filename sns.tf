#Serviço de Notificação - AWS SNS

#1. Cria o Canal de Notificação (SNS Topic) para envio de alertas via e-mail
resource "aws_sns_topic" "sns_alerts" {
  name = "${var.project_name}-sns-alerts"
}

#2. Inscreve o seu e-mail no canal de notificação (SNS Topic) para receber alertas
resource "aws_sns_topic_subscription" "sns_email_subscription" {
    topic_arn = aws_sns_topic.sns_alerts.arn
    protocol  = "email"
    endpoint  = "email@email.com" # Substitua pelo seu e-mail
}
