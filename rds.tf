

resource "aws_db_subnet_group" "rds_subnets" {
  name       = "rds-subnet-group"
  subnet_ids = var.private_subnets
  tags = {
    Name = "rds-subnet-group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier              = "my-postgres-db"
  engine                  = "postgres"
  engine_version          = "15.3"  # adjust as needed
  instance_class          = "db.t3.medium"
  allocated_storage       = 20
  storage_type            = "gp2"
  username                = "admin"
  password                = "ChangeMe123!"  # ideally, use secrets manager or Terraform variable
  db_subnet_group_name    = aws_db_subnet_group.rds_subnets.name
  vpc_security_group_ids  = [module.myapp-vpc.default_security_group_id]
  multi_az                = false
  skip_final_snapshot     = true
  publicly_accessible     = false
  deletion_protection     = false
  backup_retention_period = 7
  tags = {
    Environment = "dev"
  }
}
