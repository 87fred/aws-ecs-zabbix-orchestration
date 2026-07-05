# =============================================================
# OUTPUTS DE ACESSO ÀS APLICAÇÕES (ZABBIX & GRAFANA)
# =============================================================

output "alb_dns_name" {
  description = "O endereço DNS público do Application Load Balancer"
  value       = aws_lb.alb.dns_name
}

output "zabbix_url" {
  description = "URL de acesso para a interface Web do Zabbix"
  value       = "http://${aws_lb.alb.dns_name}"
}

output "grafana_url" {
  description = "URL de acesso para os dashboards do Grafana"
  value       = "http://${aws_lb.alb.dns_name}:3000"
}