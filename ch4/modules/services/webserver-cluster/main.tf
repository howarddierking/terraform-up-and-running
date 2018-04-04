data "aws_availability_zones" "all" {}

data "template_file" "user_data" {
  template = "${file("user-data.sh")}"

  vars {
    server_port = "${vars.server_port}"
  }
}


# --- resources ---

resource "aws_launch_configuration" "example" {
  image_id = "ami-40d28157"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]
  associate_public_ip_address = "false" # change to false since we'll be behind an elb

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
  # availability_zones = ["${data.aws_availability_zones.all.names}"] # NOTE: this example code probably worked fine in the default VPC, but alas, that's not the world I'm living in
  vpc_zone_identifier = ["subnet-02635a2d"] # required for adding into a non-default VPC (and possibly non-legacy ec2 according to the docs)

  # tell instances to register with the load balancer
  load_balancers = ["${aws_elb.example.name}"]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}




resource "aws_elb" "example" {
  name = "terraform-elb-example"
  # availability_zones = ["${data.aws_availability_zones.all.names}"]
  # availability_zones = ["us-east-1a"] # hard-coded because classic ELBs are not supported in us-east-1f. NOTE: if using subnets, you can't specify the AZs
  # error: InvalidConfigurationRequest: Security group(s) can be applied to only an ELB in VPC.
  subnets = ["subnet-02635a2d"]
  security_groups = ["${aws_security_group.elb.id}"]

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "${var.server_port}"
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:${var.server_port}/"
  }
}




resource "aws_security_group" "elb" {
  name = "terraform-example-elb"
  vpc_id = "vpc-cc64f0b7" # added because not using default VPC

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # this rule is needed to enable ELB healthchecks
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}