# Output para o link de acesso ao Zabbix
output "zabbix_url" {
  description = "Link de acesso à interface Web do Zabbix"
  value       = "http://${aws_lb.alb.dns_name}" # Porta 80 é o padrão do HTTP, não precisa digitar :80
}

# Output para o link de acesso ao Grafana
output "grafana_url" {
  description = "Link de acesso ao painel do Grafana"
  value       = "http://${aws_lb.alb.dns_name}:3000" # Mapeia a porta 3000 do Grafana
}