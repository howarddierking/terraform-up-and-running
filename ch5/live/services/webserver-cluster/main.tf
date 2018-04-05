terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-state-731230173806"
    key = "ch5/live/services/webserver-cluster/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster" 

  cluster_name = "webservers-prod"
  enable_autoscaling = false
}