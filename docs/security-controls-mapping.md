# Security Controls Mapping

## 1. Objective

This document maps the main security risks identified in the project to the controls implemented in the AWS foundation.

The goal is to demonstrate how each architectural decision contributes to reducing a specific security risk.

## 2. Controls Overview

| Security Domain | Implemented Control | AWS Component |
|---|---|---|
| Network segmentation | Public, application and database layers are separated | VPC, Subnets |
| Traffic filtering | Only required flows are allowed | Security Groups |
| Database protection | Database layer is not publicly reachable | Private subnet, DB SG |
| Audit logging | Administrative actions are recorded | CloudTrail |
| Threat detection | Suspicious behavior is monitored | GuardDuty |
| Security posture | Security best practices are monitored | Security Hub |
| Encryption at rest | Security logs are encrypted | KMS, S3 SSE-KMS |
| Log protection | Logs are versioned and not public | S3 Versioning, Public Access Block |
| Infrastructure consistency | Infrastructure is deployed as code | Terraform |

## 3. Risk-to-Control Mapping

| Risk | Security Control | Implementation |
|---|---|---|
| Public exposure of backend services | Backend resources are placed in private subnets | `aws_subnet.private_app`, `aws_subnet.private_db` |
| Direct database access from internet | Database SG only accepts traffic from app SG | `aws_security_group.db` |
| Application layer exposed directly | App SG only accepts traffic from ALB SG | `aws_security_group.app` |
| Excessive public inbound traffic | Public SG only allows HTTP/HTTPS | `aws_security_group.alb` |
| Loss of audit trail | AWS API activity is logged | `aws_cloudtrail.main` |
| Log tampering | Logs are versioned | `aws_s3_bucket_versioning.security_logs` |
| Log disclosure | Public access is blocked | `aws_s3_bucket_public_access_block.security_logs` |
| Weak log confidentiality | Logs are encrypted using KMS | `aws_kms_key.logs` |
| Undetected suspicious behavior | Threat detection is enabled | `aws_guardduty_detector.main` |
| Security misconfiguration | Security best practices are monitored | `aws_securityhub_account.main` |
| Manual deployment mistakes | Terraform is the source of truth | Terraform configuration files |

## 4. Zero Trust Alignment

| Zero Trust Principle | Project Implementation |
|---|---|
| Never trust, always verify | No implicit access between layers |
| Least privilege | Security groups allow only required flows |
| Assume breach | GuardDuty and CloudTrail improve detection and investigation |
| Minimize blast radius | Segmented network architecture |
| Protect data | Logs encrypted with KMS |
| Continuous monitoring | Security Hub and GuardDuty enabled |

## 5. Current Limitations

The current version provides a strong AWS security foundation, but some controls are planned for future iterations:

- AWS WAF in front of the application entry point
- IAM Access Analyzer
- VPC endpoints
- Budget alarms
- CI/CD security scanning
- Azure equivalent controls
- Automated alerting workflow

## 6. Next Improvements

The next versions will focus on:

1. Adding AWS WAF and ALB
2. Adding DevSecOps pipeline checks
3. Adding Azure foundation
4. Adding attack simulation documentation
5. Adding architecture diagrams
