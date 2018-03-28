# TODO - figure out what's missing to get this to succesfully launch in a non-default VPC
# AWS error: Launching a new EC2 instance. Status Reason: VPC security groups may not be used for a non-VPC launch. Launching EC2 instance failed.

provider "aws" {
  region = "us-east-1"
}

# --- variables ---

variable "server_port" {
  type = "string"
  description = "The port the server will use for HTTP requests"
  default = "8080"
}

data "aws_availability_zones" "all" {}

# --- resources ---

resource "aws_launch_configuration" "example" {
  image_id = "ami-40d28157"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]
  # associate_public_ip_address = "true"

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World" > index.html
    nohup busybox httpd -f -p "${var.server_port}" &
    EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "instance" {
  name = "allow-terraform-instance-http"
  vpc_id = "vpc-cc64f0b7"

  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.example.id}"
  availability_zones = ["${data.aws_availability_zones.all.names}"]

  min_size = 2
  max_size = 10

  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}


# --- outputs ---

