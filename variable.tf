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