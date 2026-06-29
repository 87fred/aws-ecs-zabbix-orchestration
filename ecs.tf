#Criacao do cluster ECS
resource "aws_ecs_cluster" "ecs-cluster-zabbix" {
  name = "${var.project_name}-ecs-cluster-zabbix"
  setting {
    name  = "containerInsights" #Ativa o painel de monitoramento do ECS no CloudWatch
    value = "enabled"           #Coleta métricas de CPU, memória e rede dos containers

  }

  tags = {
    Name = "${var.project_name}-ecs-cluster-zabbix"
  }
}
#Vincula a estratégia de capacidade serveless ao cluster criado, permitindo que o ECS gerencie automaticamente a alocação de recursos para as tarefas.
resource "aws_ecs_cluster_capacity_providers" "ecs-cluster-zabbix" {
  cluster_name       = aws_ecs_cluster.ecs-cluster-zabbix.name # CORRIGIDO: Removido 'aaws_' para 'aws_'
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  default_capacity_provider_strategy {
    base              = 1
    capacity_provider = "FARGATE"
    weight            = 100
  }
}
#Permissoes de execucoes - IAM Roles
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.project_name}-ecs-execution-role"

  #Define a politica de confiança permitindo o serviço de ECS (ecs-tasks) está autorizado a assumir a identity.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ecs-execution-role"
  }
}

#Anexa a politica padrão gerenciada pela AWS (AmazonECSTaskExecutionRolePolicy) na role que criamos acima
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_secrets_policy" {
  name = "${var.project_name}-ecs-secrets-policy"
  role = aws_iam_role.ecs_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          data.aws_secretsmanager_secret.bootstrap_secret.arn
        ]
      }
    ]
  })
}

#Grupo de logs no CLoudwatch
#Cria o repositório de logs para o container do Zabbix
resource "aws_cloudwatch_log_group" "zabbix_log_group" {
  name              = "/ecs/${var.project_name}-zabbix"
  retention_in_days = 5 #Define o período de retenção dos logs (em dias)

  tags = {
    Name = "${var.project_name}-zabbix-log-group"
  }
}

#Cria o repositório de logs para o container do Grafana
resource "aws_cloudwatch_log_group" "grafana_log_group" {
  name              = "/ecs/${var.project_name}-grafana"
  retention_in_days = 5 #Define o período de retenção dos logs (em dias)
  tags = {
    Name = "${var.project_name}-grafana-log-group"
  }
}
#Definicao da task do Zabbix
resource "aws_ecs_task_definition" "zabbix_task" {
  family                   = "${var.project_name}-zabbix"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "zabbix-server"
      image     = "zabbix/zabbix-server-pgsql:alpine-6.4-latest"
      essential = true
      
      environment = [
        { name = "DB_SERVER_HOST", value = aws_db_instance.zabbix_rds.address },
        { name = "DB_SERVER_PORT", value = tostring(aws_db_instance.zabbix_rds.port) },
        { name = "POSTGRES_DB",    value = var.rds_db_name }
      ]

      secrets = [
        { name = "POSTGRES_USER",     valueFrom = "${data.aws_secretsmanager_secret.bootstrap_secret.arn}:username::" },
        { name = "POSTGRES_PASSWORD", valueFrom = "${data.aws_secretsmanager_secret.bootstrap_secret.arn}:password::" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.zabbix_log_group.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "server"
        }
      }
    },
    {
      name      = "zabbix-web"
      image     = "zabbix/zabbix-web-nginx-pgsql:alpine-6.4-latest"
      essential = true
      
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "DB_SERVER_HOST", value = aws_db_instance.zabbix_rds.address },
        { name = "DB_SERVER_PORT", value = tostring(aws_db_instance.zabbix_rds.port) },
        { name = "POSTGRES_DB",    value = var.rds_db_name },
        { name = "ZBX_SERVER_HOST", value = "127.0.0.1" },
        { name = "PHP_TZ",          value = var.app_timezone }
      ]

      secrets = [
        { name = "POSTGRES_USER",     valueFrom = "${data.aws_secretsmanager_secret.bootstrap_secret.arn}:username::" },
        { name = "POSTGRES_PASSWORD", valueFrom = "${data.aws_secretsmanager_secret.bootstrap_secret.arn}:password::" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.zabbix_log_group.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "web"
        }
      }
    }
  ]) # Fecha o jsonencode e a lista de containers
} # Fecha o recurso aws_ecs_task_definition