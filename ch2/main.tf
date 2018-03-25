provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami = "ami-40d28157"
  instance_type = "t2.micro"
  subnet_id = "subnet-02635a2d"
  tags {
    Name="terraform-example"
  }
}