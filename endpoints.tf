# =============================================================
# VPC ENDPOINTS (AWS PRIVATELINK)
# =============================================================

# Endpoint para o CloudWatch Logs (Permite envio de logs sem internet)
resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.us-east-1.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]

  tags = {
    Name = "vpce-cloudwatch-logs"
  }
}

# Endpoint para a API do ECR (Autenticação do ECS no registro)
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.us-east-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]

  tags = {
    Name = "vpce-ecr-api"
  }
}

# Endpoint para o ECR Docker (Permite baixar as camadas das imagens)
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.us-east-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]

  tags = {
    Name = "vpce-ecr-dkr"
  }
}