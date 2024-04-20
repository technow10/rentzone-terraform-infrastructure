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
variable "private_data_subnet_data1_cidr" {}
variable "private_data_subnet_data2_cidr" {}

#create security groups variable in modules
variable "ssh-ip" {}

# Create RDS variable
#variable "private_data_subnet_az1_id" {}
#variable "private_data_subnet_az2_id" {}
#variable "database_snapshot_identifier" {}
#variable "database_instance_class" {}
#variable "availability_zone_1" {}
#variable "db_instance_identifier" {}
#variable "multi_az_deployment" {}
#variable "database_security_group_id" {}
