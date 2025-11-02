terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "demo" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "demo-vpc" }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.demo.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
  tags = { Name = "demo-public-a" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.demo.id
  tags = { Name = "demo-igw" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.demo.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "demo-public-rt" }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "web_sg" {
  name        = "demo-web-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.demo.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "all out"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "demo-web-sg" }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_key_pair" "demo" {
  key_name   = var.key_name
  public_key = var.public_key
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"   # was t2.micro
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.demo.key_name
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    echo "<h1>Hello from Terraform on $(hostname)</h1>" > /var/www/html/index.html
    systemctl enable nginx
    systemctl restart nginx
  EOF
  tags = { Name = "terraform-ec2-demo" }
}

