
variable "rds_username" {}
variable "rds_port" {}

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
  vpc_security_group_ids = [module.eks.cluster_security_group_id]
  subnet_ids             = module.myapp-vpc.private_subnets

  skip_final_snapshot = true
  family = "postgres15"
}




