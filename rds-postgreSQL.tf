


variable "rds_username" {}
variable "rds_password" {}
variable "rds_port" {}

module "rds_postgres" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "my-postgres-db"

  engine            = "postgres"
  engine_version    = "14.7"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name     = "myappdb" 
  username = var.rds_username
  password = var.rds_password
  port     = var.rds_port 
  

  publicly_accessible    = false
  vpc_security_group_ids = [module.myapp-vpc.default_security_group_id]
  subnet_ids             = module.vpc.private_subnets

  skip_final_snapshot = true
}




