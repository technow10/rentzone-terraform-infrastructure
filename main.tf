locals {
  region       = var.region
  project_name = var.project_name
  environment  = var.environment
}

# Create VPC module

module "vpc" {
  source                         = "git@github.com:technow10/rentzone-terraform-modules.git//VPC"
  region                         = local.region
  project_name                   = local.project_name
  environment                    = local.environment
  vpc_cidr                       = var.vpc_cidr
  public_subnet_az1_cidr         = var.public_subnet_az1_cidr
  public_subnet_az2_cidr         = var.public_subnet_az2_cidr
  private_app_subnet_az1_cidr    = var.private_app_subnet_az1_cidr
  private_app_subnet_az2_cidr    = var.private_app_subnet_az2_cidr
  private_data_subnet_data1_cidr = var.private_data_subnet_data1_cidr
  private_data_subnet_data2_cidr = var.private_data_subnet_data2_cidr
}

# Create a NAT Gateway repository

module "Nat-gw" {
  source       = "git@github.com:technow10/rentzone-terraform-modules.git//Nat_Gateway"
  project_name = local.project_name
  environment  = local.environment

  # VPC s for NAT Gateway modules
  vpc_id                     = module.vpc.vpc_id
  internet_gateway           = module.vpc.internet_gateway
  public_subnet_az1_id       = module.vpc.public_subnet_az1_id
  public_subnet_az2_id       = module.vpc.public_subnet_az2_id
  private_app_subnet_az1_id  = module.vpc.private_app_subnet_az1_id
  private_app_subnet_az2_id  = module.vpc.private_app_subnet_az2_id
  private_data_subnet_az1_id = module.vpc.private_data_subnet_az1_id
  private_data_subnet_az2_id = module.vpc.private_data_subnet_az2_id

}

# Create security group

module "security-group" {
  source       = "git@github.com:technow10/rentzone-terraform-modules.git//security-group"
  project_name = local.project_name
  environment  = local.environment
  vpc_id       = module.vpc.vpc_id
  ssh-ip       = var.ssh-ip
}

#create RDS modules

# Create RDS variable
module "rds" {
  source                       = "git@github.com:technow10/rentzone-terraform-modules.git//rds"
  project_name                 = local.project_name
  environment                  = local.environment
  private_data_subnet_az1_id   = module.vpc.private_data_subnet_az1_id
  private_data_subnet_az2_id   = module.vpc.private_data_subnet_az2_id
  database_snapshot_identifier = var.database_snapshot_identifier
  database_instance_class      = var.database_instance_class
  availability_zone_1          = module.vpc.availability_zone_1
  db_instance_identifier       = var.db_instance_identifier
  multi_az_deployment          = var.multi_az_deployment
  database_security_group_id   = module.security-group.database_security_group_id
}