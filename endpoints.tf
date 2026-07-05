#1. VPC ENDPOINTS (PRIVATELINK)

#Endpoint para o ECR API - Necessario para autenticacao do ECS herdar permissoes do ECR
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = aws_vpc.main.id                   # Vincula o túnel à nossa VPC principal
  service_name      = "com.amazonaws.us-east-1.ecr.api" # Endereço oficial da API do ECR na AWS
  vpc_endpoint_type = "Interface"                       # Tipo Interface (cria placas de rede na subnet)


  #Insere o tunel dentro das duas subnets privadas
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  #Protege o tunel com o SG que foi criado
  security_group_ids = [
    aws_security_group.vpc_endpoint_sg.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "vpce-ecr-api"
  }
}

# 2. TÚNEL PARA O ECR DKR (Para o ECS conseguir baixar as camadas das imagens Docker)

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.ecr.dkr" # Endereço do gerenciador de registros Docker
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  security_group_ids = [
    aws_security_group.vpc_endpoint_sg.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "vpce-ecr-dkr" # Nome amigável do túnel de download
  }
}

#3. TÚNEL PARA O CLOUDWATCH LOGS (Para os containers enviarem os logs sem internet)
resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.logs" # Endereço do serviço CloudWatch Logs
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  security_group_ids = [
    aws_security_group.vpc_endpoint_sg.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "vpce-cloudwatch-logs" # Nome amigável do túnel de logs
  }
}
