# AWS Cloud Infrastructure with Terraform

Production-style AWS infrastructure provisioned entirely with Terraform (Infrastructure as Code). Includes automated CI/CD pipeline via GitHub Actions.

## Architecture
- **VPC** — isolated private network with public subnet
- **EC2** — t3.micro web server (Amazon Linux 2)
- **S3** — private logging bucket with public access blocked
- **IAM** — least-privilege roles and policies
- **Security Groups** — restrictive inbound/outbound rules
- **CloudWatch** — CPU utilization alarm (threshold: 80%)
- **GitHub Actions** — automated terraform plan on every push

## Tech Stack
Terraform | AWS | GitHub Actions | Python | Bash

## How to Deploy
```bash
terraform init
terraform plan
terraform apply
```

## How to Destroy
```bash
terraform destroy
```

## CI/CD Pipeline
Every push to main triggers an automated `terraform plan` to validate infrastructure code before any changes are applied.
