# Secure Multi-Cloud Zero Trust Architecture

## Overview
This project demonstrates the design and implementation of a secure multi-cloud architecture based on Zero Trust principles, Infrastructure as Code, and DevSecOps practices.
The goal is to build a cloud security architecture blueprint across AWS and Azure, focusing on network segmentation, least privilege access, encryption, logging, threat detection, and automated security validation.

## Objectives
- Design a secure cloud foundation using AWS and Azure
- Apply Zero Trust principles to cloud infrastructure
- Implement network segmentation across public, application, and database layers
- Enforce least privilege access through IAM/RBAC and security groups
- Centralize security logs and enable cloud-native threat detection
- Automate infrastructure deployment using Terraform
- Integrate security checks into a DevSecOps pipeline

## Current Scope

### AWS Foundation
The AWS part currently includes:
- VPC with DNS support enabled
- Public subnet
- Private application subnet
- Private database subnet
- Internet Gateway and public route table
- Least-privilege Security Groups:
  - ALB layer exposed only on HTTP/HTTPS
  - Application layer accessible only from ALB
  - Database layer accessible only from application layer
- Encrypted S3 bucket for security logs, TLS-only access enforced by bucket policy
- KMS key with key rotation enabled
- CloudTrail enabled for audit logging, with least-privilege bucket and key policies scoped to this trail and account (`aws:SourceArn` / `aws:SourceAccount`)
- GuardDuty enabled for threat detection
- Security Hub enabled with AWS Foundational Security Best Practices
- Public Application Load Balancer as the controlled internet-facing entry point
- AWS WAF associated with the ALB
- AWS Managed Rules:
  - Common Rule Set
  - Known Bad Inputs Rule Set

### Azure Foundation
The Azure part will include:
- Virtual Network
- Public, application, and database subnets
- Network Security Groups
- Key Vault
- Defender for Cloud
- Log Analytics workspace
- Diagnostic settings

## Architecture Principles
This project follows the following security principles:
- Deny by default
- Least privilege
- No direct database exposure
- Segmentation between public, application, and data layers
- Encryption at rest
- Centralized logging
- Cloud-native threat detection
- Infrastructure as Code
- Security validation in CI/CD

## Repository Structure
```text
secure-multicloud-zero-trust/
├── architecture/
│   └── diagrams/
├── docs/
├── pipeline/
├── terraform/
│   ├── aws/
│   ├── azure/
│   └── modules/
├── README.md
└── .gitignore
```

## AWS Deployment

Go to the AWS Terraform directory:
```bash
cd terraform/aws
```

Initialize Terraform:
```bash
terraform init
```

Format and validate:
```bash
terraform fmt
terraform validate
```

Preview the deployment:
```bash
terraform plan -var-file=dev.tfvars
```

Apply the infrastructure:
```bash
terraform apply -var-file=dev.tfvars
```

Destroy the infrastructure after testing:
```bash
terraform destroy -var-file=dev.tfvars
```

## Security Controls Mapping

| Risk | Control |
|------|---------|
| Public database exposure | Database subnet is private and DB security group only allows traffic from app layer |
| Excessive network exposure | Security groups enforce strict traffic flows |
| Lack of audit trail | CloudTrail is enabled |
| Threat detection gap | GuardDuty is enabled |
| Weak data protection | S3 logs are encrypted using KMS |
| Public access to logs | S3 public access block is enabled |
| Log bucket or key abused by another trail or account (confused deputy) | Bucket and KMS key policies only allow CloudTrail for this trail ARN and account |
| Log interception in transit | Bucket policy denies any request not made over TLS |
| Uncontrolled infrastructure changes | Terraform provides reproducible deployments |
| Web application attacks | AWS WAF is associated with the public ALB |
| Uncontrolled public entry point | ALB acts as the only public application entry point |
| Known malicious payloads | AWS Managed WAF rules detect common and bad input patterns |

## Roadmap
- Add AWS WAF and Application Load Balancer
- Add private routing and NAT strategy
- Add VPC endpoints
- Add Azure foundation
- Add GitHub Actions DevSecOps pipeline
- Add Checkov, tfsec, Trivy, and Gitleaks scans
- Add threat model documentation
- Add architecture diagrams
- Add attack simulation and remediation write-up

## Author
**Kamil MANDI**
Engineering student focused on Cloud Security, DevSecOps, and Infrastructure Automation.