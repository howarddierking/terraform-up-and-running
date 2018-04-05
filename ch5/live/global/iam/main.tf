provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-state-731230173806"
    key = "ch5/live/global/iam/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}


resource "aws_iam_user" "example" {
  count = "${length(var.user_names)}"
  name = "${element(var.user_names, count.index)}"
}