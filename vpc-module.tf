#vpc aws module 
provider "aws" {
  
}

variable cidr  {} 
variable private_subnets {} 
variable public_subnets  {} 
variable name {}

data "aws_availability_zones" "available" {
  state = "available"
}

module "myapp-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"
  name = var.name
  cidr = var.cidr
  azs             = data.aws_availability_zones.available.names
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets  
  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true
  enable_dns_support = true
  map_public_ip_on_launch = true
  tags = {
    "kubernetes.io/cluster/myapp" = "shared"
    "Name" = var.name
    "CreatedBy" = "Asue Derick" 
    "CreatedOn" = "2025-07-24"
    "Environment" = "Development"
    "Project" = "EKS Cluster"
    "ManagedBy" = "Terraform"
    "Terraform" = "true"
    "TerraformVersion" = "1.12.2"
  }
  public_subnet_tags = {
    "kubernetes.io/role/external-elb" = "1"
    "kubernetes.io/cluster/myapp-eks-cluster" = "shared" 
    }
    private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/myapp-eks-cluster" = "shared"  
    }
}
