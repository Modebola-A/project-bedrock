data "aws_caller_identity" "current" {}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  vpc_name             = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  cluster_name         = var.cluster_name
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# EKS Module
module "eks" {
  source = "./modules/eks"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  node_instance_type = var.node_instance_type
  node_desired_size  = var.node_desired_size
  node_min_size      = var.node_min_size
  node_max_size      = var.node_max_size

  depends_on = [module.vpc]
}

# RDS Module
module "rds" {
  source = "./modules/rds"

  cluster_name           = var.cluster_name
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  node_security_group_id = module.eks.node_security_group_id
  db_username            = var.db_username
  db_password            = var.db_password
  db_instance_class      = "db.t3.micro"

  depends_on = [module.eks]
}

# S3 + Lambda Module
module "s3" {
  source = "./modules/s3"

  student_id    = var.student_id
  dev_user_name = "bedrock-dev-view"

  depends_on = [module.iam]
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  cluster_name = var.cluster_name
  account_id   = data.aws_caller_identity.current.account_id

  depends_on = [module.eks]
}
