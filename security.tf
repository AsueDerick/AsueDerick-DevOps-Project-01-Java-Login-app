resource "aws_security_group" "rds_postgres_sg" {
  name        = "rds-postgres-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = module.myapp-vpc.vpc_id
  ingress {
    description      = "PostgreSQL from EKS nodes"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
  }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name        = "rds-postgres-sg"
        Environment = "Development"
        Project     = "EKS Cluster"
        ManagedBy   = "Terraform"
        Terraform   = "true"
        CreatedBy   = "Asue Derick"
        CreatedOn   = "2025-07-24"
    }
}