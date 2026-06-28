#Leitura do login/senha do AWS Secret Manager
data "aws_secretsmanager_secret" "bootstrap_secret" {
  name = "${var.project_name}-rds-secret-v1"
}

data "aws_secretsmanager_secret_version" "bootstrap_secret_version" {
  secret_id = data.aws_secretsmanager_secret.bootstrap_secret.id
}

locals {
  db_credentials = jsondecode(data.aws_secretsmanager_secret_version.bootstrap_secret_version.secret_string)
}

#Grupo de subnets para o RDS
resource "aws_db_subnet_group" "zabbix_rds_subnet_group" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "${var.project_name}-rds-subnet-group"
  }
}

#Instancia do RDS Postgres
resource "aws_db_instance" "zabbix_rds" {
  identifier             = "${var.project_name}-rds-instance"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "15.7"
  instance_class         = "db.t3.micro"
  db_name                = var.rds_db_name
  username               = local.db_credentials.username
  password               = local.db_credentials.password
  parameter_group_name   = var.db_parameter_group_name
  db_subnet_group_name   = aws_db_subnet_group.zabbix_rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  skip_final_snapshot = true
  publicly_accessible = false

  tags = {
    Name = "${var.project_name}-rds-instance"
  }
}