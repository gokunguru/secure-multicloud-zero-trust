# Threat Model

## 1. Scope

This threat model covers the first version of the Secure Multi-Cloud Zero Trust Architecture project.

The current scope focuses on the AWS foundation, including:

- VPC
- Public subnet
- Private application subnet
- Private database subnet
- Security groups
- Encrypted security logs bucket
- KMS key
- CloudTrail
- GuardDuty
- Security Hub

The objective is to identify the main threats that could affect the architecture and document the security controls used to reduce the associated risks.

## 2. Critical Assets

| Asset | Description | Security Objective |
|---|---|---|
| Cloud identities | IAM users, roles and permissions | Prevent privilege escalation and unauthorized access |
| Network boundaries | VPC, subnets, route tables and security groups | Limit exposure and control traffic flows |
| Application layer | Private application resources | Prevent direct internet exposure |
| Database layer | Private database resources | Prevent unauthorized data access |
| Security logs | CloudTrail and security-related logs | Preserve auditability and incident investigation capability |
| KMS key | Encryption key used for log protection | Protect sensitive log data |
| Terraform code | Infrastructure as Code repository | Prevent insecure infrastructure changes |

## 3. Trust Boundaries

The main trust boundaries are:

1. Internet → Public subnet  
2. Public subnet → Private application subnet  
3. Private application subnet → Private database subnet  
4. AWS account → Terraform deployment workflow  
5. Cloud services → Security logs bucket  

Each boundary requires explicit controls and should not rely on implicit trust.

## 4. Threats and Mitigations

| Threat | Example Scenario | Impact | Mitigation |
|---|---|---|---|
| Public database exposure | A database security group allows `0.0.0.0/0` on port 5432 | Data breach | DB SG only allows traffic from app SG |
| Direct access to application layer | App servers are exposed to the internet | Increased attack surface | App SG only allows traffic from ALB SG |
| Excessive public exposure | Public subnet allows unnecessary inbound ports | Remote exploitation | Only HTTP/HTTPS allowed on ALB SG |
| Lack of auditability | Admin actions are not logged | Difficult incident investigation | CloudTrail enabled |
| Log tampering or deletion | Logs are modified after an incident | Loss of evidence | S3 versioning enabled |
| Log exposure | Security logs are publicly accessible | Information leakage | S3 public access block enabled |
| Weak data protection | Logs stored without encryption | Sensitive data exposure | S3 encryption with KMS |
| Compromised cloud behavior | Suspicious API activity goes unnoticed | Delayed detection | GuardDuty enabled |
| Misconfiguration drift | Security posture degrades over time | Increased risk | Security Hub enabled |
| Manual configuration error | Resources are created manually with weak settings | Misconfiguration | Terraform used as source of truth |

## 5. STRIDE Analysis

| STRIDE Category | Relevant Risk | Control |
|---|---|---|
| Spoofing | Unauthorized identity use | IAM least privilege, future MFA enforcement |
| Tampering | Modification of logs or infrastructure | S3 versioning, Terraform version control |
| Repudiation | No trace of admin actions | CloudTrail |
| Information Disclosure | Public logs or database exposure | Private subnets, SG restrictions, KMS encryption |
| Denial of Service | Public endpoint abuse | Future WAF and rate limiting |
| Elevation of Privilege | Overly broad IAM permissions | Future IAM policy hardening and scanning |

## 6. Attack Path Example

### Scenario

An attacker scans the public IP range and tries to access backend resources directly.

### Expected Result

The attacker should only be able to reach the public entry point.

The application layer and database layer should not be directly reachable from the internet.

### Controls Involved

- Public/private subnet separation
- Security groups
- No direct DB exposure
- CloudTrail logging
- GuardDuty detection

## 7. Residual Risks

Some risks remain and will be addressed in future versions:

- No WAF deployed yet
- No CI/CD security scanning yet
- No IAM policy analyzer yet
- No VPC endpoints yet
- No automated alerting workflow yet
- Azure foundation not implemented yet

## 8. Future Improvements

Planned improvements:

- Add AWS WAF in front of the ALB
- Add VPC endpoints for private access to AWS services
- Add Checkov and tfsec for Terraform security scanning
- Add Gitleaks for secret detection
- Add Trivy for container image scanning
- Add IAM Access Analyzer
- Add Azure threat model equivalent
- Add attack simulation and remediation documentation
