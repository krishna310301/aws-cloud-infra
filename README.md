# AWS Cloud Infrastructure with Terraform

Production-style AWS infrastructure provisioned entirely with Terraform (Infrastructure as Code). Features a live webpage served from EC2, automated CI/CD pipeline via GitHub Actions, and CloudWatch monitoring.

## Live Demo
Deployed at a public EC2 IP — rebuild anytime with `terraform apply`

## Architecture
- **VPC** — isolated private network with public subnet in us-east-2
- **EC2** — t3.micro web server (Amazon Linux 2) serving a live webpage
- **S3** — private logging bucket with public access blocked
- **IAM** — least-privilege roles, no root credentials used
- **Security Groups** — only ports 80 (HTTP) and 22 (SSH) allowed
- **CloudWatch** — CPU utilization alarm at 80% threshold

## Webpage
A professional landing page served from EC2, downloaded from GitHub on startup. Shows the full architecture interactively with animated counters, infrastructure cards, CI/CD pipeline diagram, and tech stack.

## CI/CD Pipeline
Every push to main triggers GitHub Actions which runs `terraform init` and `terraform plan` automatically — validating all infrastructure code before any deployment.

## How to Deploy
```bash
terraform init
terraform plan
terraform apply
```

## How to Update Webpage
```bash
# Edit html/index.html
git add html/index.html
git commit -m "Update webpage"
git push origin main
terraform destroy -auto-approve && terraform apply -auto-approve
```

## How to Destroy
```bash
terraform destroy
```

## Tech Stack
Terraform | AWS EC2 | VPC | S3 | IAM | CloudWatch | GitHub Actions | Python | Bash