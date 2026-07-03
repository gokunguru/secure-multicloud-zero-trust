resource "aws_kms_key" "logs" {
  description             = "KMS key for encrypting security logs"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-kms-logs"
  })
}

resource "aws_kms_alias" "logs" {
  name          = "alias/${local.name_prefix}-logs"
  target_key_id = aws_kms_key.logs.key_id
}

resource "aws_s3_bucket" "security_logs" {
  bucket = "${local.name_prefix}-security-logs-${data.aws_caller_identity.current.account_id}"

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-security-logs"
  })
}

resource "aws_s3_bucket_versioning" "security_logs" {
  bucket = aws_s3_bucket.security_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "security_logs" {
  bucket = aws_s3_bucket.security_logs.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.logs.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "security_logs" {
  bucket = aws_s3_bucket.security_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudtrail" "main" {
  name                          = "${local.name_prefix}-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.security_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
  enable_log_file_validation    = true

  kms_key_id = aws_kms_key.logs.arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-cloudtrail"
  })
}

resource "aws_guardduty_detector" "main" {
  enable = true

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-guardduty"
  })
}

resource "aws_securityhub_account" "main" {}

resource "aws_securityhub_standards_subscription" "aws_foundational" {
  depends_on    = [aws_securityhub_account.main]
  standards_arn = "arn:aws:securityhub:${var.aws_region}::standards/aws-foundational-security-best-practices/v/1.0.0"
}