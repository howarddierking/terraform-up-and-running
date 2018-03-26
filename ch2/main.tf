provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami = "ami-40d28157"
  instance_type = "t2.micro"
  subnet_id = "subnet-02635a2d"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  associate_public_ip_address = "true"

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World" > index.html
    nohup busybox httpd -f -p 8080 &
    EOF

  tags {
    Name="terraform-example"
  }
}

resource "aws_security_group" "instance" {
  name = "allow-terraform-instance-http"
  vpc_id = "vpc-cc64f0b7"

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}