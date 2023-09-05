provider "aws" {
  region  = "us-east-1"
  profile = "new"
}

terraform {
  backend "s3" {
    bucket = "studentapp-ops-tfstate"
    key    = "terraform.tfstate"
    region = "us-east-1"
    profile = "new"
  }
}