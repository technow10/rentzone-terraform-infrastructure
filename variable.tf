# Environment variables
variable "region" {}
variable "project_name" {}
variable "environment" {}

# Create vpc variable for the module
variable "vpc_cidr" {}
variable "public_subnet_az1_cidr" {}
variable "public_subnet_az2_cidr" {}
variable "private_app_subnet_az1_cidr" {}
variable "private_app_subnet_az2_cidr" {}
variable "private_data_subnet_az1_cidr" {}
variable "private_data_subnet_az2_cidr" {}

#create security groups variable in modules
variable "ssh-ip" {}

# Create RDS variable
variable "database_snapshot_identifier" {}
variable "database_instance_class" {}
variable "db_instance_identifier" {}
variable "multi_az_deployment" {}

# Create acm variables
variable "domain_name" {}
variable "alternative_names" {}

# create alb variable
variable "target_type" {}

# Create s3 variables
variable "env_file_bucket_name" {}
variable "env_file_name" {}

# ecs variable
variable "architecture" {}
variable "container_image" {}

# route53
variable "record_name" {}




