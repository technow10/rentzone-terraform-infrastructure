# store the terraform state file in s3 and lock with dynamodb
terraform {
  backend "s3" {
    bucket         = "terraform-remote-statefile-rentzone"
    key            = "terraform-module/rentzone/terraform-tfstate"
    region         = "us-east-1"
    profile        = "cloud-admn-user"
    dynamodb_table = "terraform-state-lock-rentzone"
  }
}