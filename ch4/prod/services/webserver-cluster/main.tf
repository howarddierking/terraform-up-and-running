terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-state-731230173806"
    key = "ch4/prod/services/webserver-cluster/terraform.tfstate"
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
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  scheduled_action_name = "scale_out_during_business_hours"
  autoscaling_group_name = "${module.webserver_cluster.asg_name}"

  min_size = 2
  max_size = 10
  desired_capacity = 10
  recurrence = "0 9 * * *"
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name = "scale_in_at_night"
  autoscaling_group_name = "${module.webserver_cluster.asg_name}"

  min_size = 2
  max_size = 10
  desired_capacity = 2
  recurrence = "0 17 * * *"
}