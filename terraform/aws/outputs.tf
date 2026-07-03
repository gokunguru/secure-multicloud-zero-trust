output "aws_region" {
  value = var.aws_region
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_app_subnet_id" {
  value = aws_subnet.private_app.id
}

output "private_db_subnet_id" {
  value = aws_subnet.private_db.id
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "app_security_group_id" {
  value = aws_security_group.app.id
}

output "db_security_group_id" {
  value = aws_security_group.db.id
}

output "security_logs_bucket_name" {
  value = aws_s3_bucket.security_logs.id
}

output "kms_logs_key_arn" {
  value = aws_kms_key.logs.arn
}

output "cloudtrail_name" {
  value = aws_cloudtrail.main.name
}

output "guardduty_detector_id" {
  value = aws_guardduty_detector.main.id
}

output "alb_dns_name" {
  value = aws_lb.app.dns_name
}

output "alb_arn" {
  value = aws_lb.app.arn
}

output "waf_web_acl_arn" {
  value = aws_wafv2_web_acl.main.arn
}

output "waf_web_acl_id" {
  value = aws_wafv2_web_acl.main.id
}

output "s3_vpc_endpoint_id" {
  value = aws_vpc_endpoint.s3.id
}

output "cloudwatch_logs_vpc_endpoint_id" {
  value = aws_vpc_endpoint.cloudwatch_logs.id
}

output "vpc_endpoints_security_group_id" {
  value = aws_security_group.vpc_endpoints.id
}