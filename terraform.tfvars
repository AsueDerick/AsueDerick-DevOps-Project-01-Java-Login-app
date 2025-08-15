name = "my-vpc"
cidr = "10.0.0.0/16"
private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
rds_username = "mydbuser"
rds_password = "Admin1234" # Ideally from SSM or Vault
rds_port = 5432



