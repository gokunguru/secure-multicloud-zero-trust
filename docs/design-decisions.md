# Design Decisions

## 1. Project Intent

This project aims to design a secure multi-cloud foundation using AWS and Azure, with a strong focus on security architecture, infrastructure automation, and DevSecOps practices.

The goal is not only to deploy cloud resources, but to justify the security decisions behind the architecture.

## 2. Network Segmentation

The AWS foundation uses a three-tier network model:

- Public subnet
- Private application subnet
- Private database subnet

This design reduces the attack surface by exposing only the components that require internet access.

The database layer is isolated in a private subnet and is not directly reachable from the internet.

## 3. Public Layer

The public subnet is designed to host internet-facing components such as an Application Load Balancer.

Only HTTP and HTTPS traffic are allowed at this layer.

This allows external users to reach the application entry point without exposing backend services directly.

## 4. Application Layer

The application layer is placed in a private subnet.

Application resources are not directly exposed to the internet. They only accept traffic from the public load balancer security group.

This enforces controlled traffic flow and limits lateral movement opportunities.

## 5. Database Layer

The database layer is placed in a dedicated private subnet.

The database security group only allows PostgreSQL traffic from the application security group.

This prevents direct database exposure and follows the principle of least privilege.

## 6. Security Groups Strategy

Security groups are used as stateful firewalls to enforce strict communication rules.

The traffic model is:

Internet → ALB → Application → Database

Any other direct access is denied by default.

This approach ensures that each layer only communicates with the layer it needs.

## 7. Encryption Strategy

A dedicated KMS key is used to encrypt security logs.

Key rotation is enabled to improve long-term cryptographic hygiene.

S3 server-side encryption using KMS ensures that log data is protected at rest.

## 8. Logging and Auditability

CloudTrail is enabled to record AWS API activity and administrative actions.

Security logs are stored in a dedicated S3 bucket with:

- Versioning enabled
- KMS encryption
- Public access blocked

This supports incident investigation, auditability, and compliance-oriented practices.

## 9. Threat Detection

GuardDuty is enabled to provide cloud-native threat detection.

Security Hub is enabled with AWS Foundational Security Best Practices to centralize security posture findings.

These services improve visibility over suspicious behaviors and misconfigurations.

## 10. Zero Trust Principles

This architecture follows Zero Trust principles:

- No implicit trust based on network location
- Deny by default
- Least privilege access
- Segmentation between layers
- Strong logging and monitoring
- Secrets and sensitive data protected by managed services

## 11. Infrastructure as Code

Terraform is used to make the infrastructure:

- Reproducible
- Version-controlled
- Reviewable
- Easier to audit
- Easier to destroy after testing

This also reduces manual configuration errors.

## 12. Cost Control

The project is designed as a learning and demonstration environment.

Resources should be deployed only when needed and destroyed after testing.

Future improvements should include budget alerts and cost monitoring.

## 13. NAT Gateway Strategy

Private subnets require controlled outbound internet access for use cases such as package updates, security agents, or communication with external APIs.

A NAT Gateway is deployed in the public subnet to allow resources in private subnets to initiate outbound connections without being directly reachable from the internet.

This preserves the private nature of the application and database layers while still enabling controlled outbound connectivity.

However, NAT Gateway can generate ongoing cloud costs. For this reason, this project is designed to be deployed only for testing and destroyed immediately after validation.

## 14. ALB and WAF Strategy

The Application Load Balancer is used as the controlled public entry point of the AWS architecture.

Instead of exposing application resources directly to the internet, external traffic reaches the ALB first. The application layer remains private and only accepts traffic from the ALB security group.

AWS WAF is associated with the ALB to add an application-layer protection mechanism.

The first version uses AWS managed rule groups:

- AWSManagedRulesCommonRuleSet
- AWSManagedRulesKnownBadInputsRuleSet

These rules help detect and block common web attacks and known malicious request patterns.

This design improves the security posture of the public entry point while keeping the backend layers isolated.

## 15. S3 VPC Endpoint Strategy

A Gateway VPC Endpoint for S3 is added to allow private subnets to access Amazon S3 without routing traffic through the public internet.

This improves the security posture of the private application and database layers by keeping S3 communication inside the AWS network.

The endpoint is associated with the private application and private database route tables.

This approach also reduces dependency on the NAT Gateway for S3 access.

## 16. CloudWatch Logs VPC Endpoint Strategy

An Interface VPC Endpoint for CloudWatch Logs is added to allow private resources to send logs to CloudWatch without requiring direct internet access.

The endpoint is deployed inside private subnets and protected by a dedicated security group allowing HTTPS traffic only from the VPC CIDR range.

This improves the security posture by reducing dependency on public internet paths and supporting private observability patterns.

## 17. Future Improvements

Planned improvements include:

- AWS WAF in front of the load balancer
- NAT strategy or VPC endpoints for private subnet outbound traffic
- Azure equivalent architecture
- GitHub Actions DevSecOps pipeline
- Static IaC scanning with Checkov and tfsec
- Secret scanning with Gitleaks
- Container image scanning with Trivy
- STRIDE threat model
- Attack simulation and remediation documentation
