Overview

This project provisions a complete AWS environment using Terraform.
It automatically creates a VPC, subnet, security group, and an EC2 instance running Nginx.
Terraform outputs a public URL for the Nginx web server upon deployment.

Features
- Infrastructure as Code (IaC) with Terraform
- AWS VPC, Subnet, Internet Gateway, and Security Group setup
- Ubuntu EC2 instance running Nginx
- Outputs the public web URL automatically after deployment
- Fully destroyable with a single Terraform command

Setup Instructions
1. Initialize Terraform
terraform init

2. Review planned resources
terraform plan -var="key_name=tyler-demo" -var="public_key=$(cat ~/.ssh/id_ed25519.pub)"

3. Apply configuration
terraform apply -auto-approve -var="key_name=tyler-demo" -var="public_key=$(cat ~/.ssh/id_ed25519.pub)"

4. Access web server via Terraform output 'web_url'

5. Destroy resources when done
terraform destroy -auto-approve -var="key_name=tyler-demo" -var="public_key=$(cat ~/.ssh/id_ed25519.pub)"
