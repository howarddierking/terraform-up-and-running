# command to set remote state to this s3 bucket

# terraform remote config \
# -backend=s3 \
# -backend-config="bucket=terraform-up-and-running-state-731230173806" \
# -backend-config="key=global/s3/terraform.tfstate" \
# -backend-config="region=us-east-1" \
# -backend-config="encrypt=true"

# NOTE: as of Terraform .9, this command is no longer used (https://www.terraform.io/upgrade-guides/0-9.html)

terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-state-731230173806"
    key = "global/s3/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-up-and-running-state-731230173806"  # bucket names must be unique across all of s3

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true  # will cause an error when running terraform destroy
  }
}

output "s3_bucket_arn" {
  value = "${aws_s3_bucket.terraform_state.arn}"
}