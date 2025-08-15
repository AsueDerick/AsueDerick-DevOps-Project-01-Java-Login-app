
variable "rds_username" {}
variable "rds_port" {}
resource "aws_security_group" "rds_postgres_sg" {
  name        = "rds-postgres-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = module.my_vpc.vpc_id 
  ingress {
    description      = "PostgreSQL from EKS nodes"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups  = [aws_security_group.eks_nodes_sg.id] # SG of your EKS worker nodes
  }
}


module "rds_postgres" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "my-postgres-db"

  engine            = "postgres"
  engine_version    = "14.17"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name     = "myappdb" 
  username = var.rds_username
  manage_master_user_password = true
  port     = var.rds_port 
  

  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_postgres_sg.id]
  subnet_ids             = module.myapp-vpc.private_subnets

  skip_final_snapshot = true
  family = "postgres15"
}




