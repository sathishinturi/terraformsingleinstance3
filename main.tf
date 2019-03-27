provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}
resource "aws_vpc" "default" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags {
        Name = "${var.vpc_name}"
    }
}
resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"
        tags {
        Name = "${var.IGW_name}"
    }
}
    resource "aws_subnet" "subnet1-public" {
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "${var.public_subnet1_cidr}"
    availability_zone = "ap-south-1a"
    tags {
        Name = "${var.public_subnet1_name}"
    }
}
resource "aws_subnet" "subnet2-public" {
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "${var.public_subnet2_cidr}"
    availability_zone = "ap-south-1b"
    tags {
        Name = "${var.public_subnet2_name}"
    }
}

resource "aws_route_table" "terraform-public" {
    vpc_id = "${aws_vpc.default.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }
    tags {
        Name = "${var.Main_Routing_Table}"
    }
}
resource "aws_route_table_association" "terraform-public" {
    subnet_id = "${aws_subnet.subnet1-public.id}"
    route_table_id = "${aws_route_table.terraform-public.id}"
}
resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.default.id}"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    }
}


# terraform.tf
terraform {
 backend "s3" {
 encrypt = true
 bucket = "sathish472"
 region = "ap-south-1"
 key = "pathhfile"
 }
}

data  "aws_ami" "my_ami" {
      most_recent      = true
      #name_regex       = "Sathish"
      owners           = ["552324437847"]
}
resource "aws_instance" "web-1" {
    ami = "${data.aws_ami.my_ami.id}"
    availability_zone = "ap-south-1a"
    instance_type = "t2.micro"
    key_name = "pri"
    subnet_id = "${aws_subnet.subnet1-public.id}"
    vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
    associate_public_ip_address = true	
    tags {
        Name = "Terraform-Server-${count.index}"
        Env = "Prod"
        Owner = "Sathish"
    }
    
    tags {
        Name = "ff"
        Env = "fff"
        Owner = "Sathish"
    }
}
