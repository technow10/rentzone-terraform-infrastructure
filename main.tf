locals {
  region       = var.region
  project_name = var.project_name
  environment  = var.environment
}

# Create VPC module

module "vpc" {
  source                       = "git@github.com:technow10/rentzone-terraform-modules.git//VPC"
  region                       = local.region
  project_name                 = local.project_name
  environment                  = local.environment
  vpc_cidr                     = var.vpc_cidr
  public_subnet_az1_cidr       = var.public_subnet_az1_cidr
  public_subnet_az2_cidr       = var.public_subnet_az2_cidr
  private_app_subnet_az1_cidr  = var.private_app_subnet_az1_cidr
  private_app_subnet_az2_cidr  = var.private_app_subnet_az2_cidr
  private_data_subnet_az1_cidr = var.private_data_subnet_az1_cidr
  private_data_subnet_az2_cidr = var.private_data_subnet_az2_cidr
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

# Request SSL certificate
module "ssl_certificate" {
  source            = "git@github.com:technow10/rentzone-terraform-modules.git//acm"
  domain_name       = var.domain_name
  alternative_names = var.alternative_names

}

# Create an ALB module
module "application_load_balancer" {
  source                     = "git@github.com:technow10/rentzone-terraform-modules.git//alb"
  project_name               = local.project_name
  environment                = local.environment
  alb_security_group_id      = module.security-group.alb_security_group_id
  private_data_subnet_az1_id = module.vpc.private_data_subnet_az1_id
  private_data_subnet_az2_id = module.vpc.private_data_subnet_az2_id
  target_type                = var.target_type
  vpc_id                     = module.vpc.vpc_id
  certificate_arn            = module.ssl_certificate.certificate_arn

}

# create s3 bucket
module "s3_bucket" {
  source               = "git@github.com:technow10/rentzone-terraform-modules.git//s3"
  project_name         = local.project_name
  env_file_bucket_name = var.env_file_bucket_name
  env_file_name        = var.env_file_name
}

# create ecs task execution role
module "ecs-task" {
  source               = "git@github.com:technow10/rentzone-terraform-modules.git//iam-role"
  project_name         = local.project_name
  environment          = local.environment
  env_file_bucket_name = module.s3_bucket.env_file_bucket_name


}

# create ecs task definition and service 
module "ecs" {
  source                       = "git@github.com:technow10/rentzone-terraform-modules.git//ecs"
  project_name                 = local.project_name
  environment                  = local.environment
  ecs_task_execution_role_arn  = module.ecs-task.ecs_task_execution_role_arn
  architecture                 = var.architecture
  container_image              = var.container_image
  env_file_bucket_name         = module.s3_bucket.env_file_bucket_name
  env_file_name                = module.s3_bucket.env_file_name
  region                       = local.region
  private_app_subnet_az1_id    = module.vpc.private_app_subnet_az1_id
  private_app_subnet_az2_id    = module.vpc.private_app_subnet_az2_id
  app_server_security_group_id = module.security-group.app_server_security_group_id
  alb_target_group_arn         = module.application_load_balancer.alb_target_group_arn
}

# create autoscaling group 
module "ecs_asg" {
  source       = "git@github.com:technow10/rentzone-terraform-modules.git//asg"
  project_name = local.project_name
  environment  = local.environment
  ecs_service  = modules.ecs.ecs_service

}

# Create route53 
module "route53" {
  source                             = "git@github.com:technow10/rentzone-terraform-modules.git//route53"
  domain_name                        = module.ssl_certificate.domain_name
  record_name                        = var.record_name
  application_load_balancer_dns_name = module.application_load_balancer.application_load_balancer_dns_name
  application_load_balancer_zone_id  = module.application_load_balancer.application_load_balancer_zone_id

}

# print website url
output "website_url" {
  value = join("", ["https://", var.record_name, ".", var.domain_name])

}