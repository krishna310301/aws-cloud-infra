# Provider configuration - tells Terraform to use AWS
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

# VPC - your private network on AWS
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "krishna-vpc"
    Project = "aws-cloud-infra"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "krishna-public-subnet"
    Project = "aws-cloud-infra"
  }
}

# Internet Gateway - allows internet access
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "krishna-igw"
    Project = "aws-cloud-infra"
  }
}

# Route Table - directs traffic to internet gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name    = "krishna-public-rt"
    Project = "aws-cloud-infra"
  }
}

# Associate route table with subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group - firewall rules (locks on the doors)
resource "aws_security_group" "web" {
  name        = "krishna-web-sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH from anywhere (restrict in production)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "krishna-web-sg"
    Project = "aws-cloud-infra"
  }
}

# EC2 Instance - your virtual server (the house)
resource "aws_instance" "web" {
  ami                    = "ami-0b4624933067d393a" # Amazon Linux 2 us-east-2
  instance_type          = "t3.micro"              # Free tier eligible us-east-2
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y python3
    echo "Hello from Krishna's Cloud Infrastructure!" > /var/www/html/index.html
    python3 -m http.server 80 &
  EOF

  tags = {
    Name    = "krishna-web-server"
    Project = "aws-cloud-infra"
  }
}

# S3 Bucket - storage shed
resource "aws_s3_bucket" "logs" {
  bucket = "krishna-cloud-infra-logs-${random_id.suffix.hex}"

  tags = {
    Name    = "krishna-logs-bucket"
    Project = "aws-cloud-infra"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

# S3 Bucket - block all public access (security best practice)
resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudWatch - monitoring alarm for high CPU
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "krishna-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Triggered when CPU exceeds 80% for 4 minutes"

  dimensions = {
    InstanceId = aws_instance.web.id
  }

  tags = {
    Name    = "krishna-cpu-alarm"
    Project = "aws-cloud-infra"
  }
}

# Output useful information after deployment
output "vpc_id" {
  value = aws_vpc.main.id
}

output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}

output "s3_bucket_name" {
  value = aws_s3_bucket.logs.bucket
}