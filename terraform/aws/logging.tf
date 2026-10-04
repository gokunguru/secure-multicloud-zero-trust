locals {
  account_id      = data.aws_caller_identity.current.account_id
  cloudtrail_name = "${local.name_prefix}-cloudtrail"
  # Built from its parts rather than read from aws_cloudtrail.main: the trail
  # depends on the bucket policy below, which must reference this ARN.
  cloudtrail_arn = "arn:aws:cloudtrail:${var.aws_region}:${local.account_id}:trail/${local.cloudtrail_name}"
}

# Key policy: account administrators manage the key through IAM; CloudTrail may
# only use it for this trail in this account.
data "aws_iam_policy_document" "logs_kms" {
  # In a key policy, resources = ["*"] means this key only. The root statement is
  # AWS's default key policy: without it the key becomes unmanageable.
  #checkov:skip=CKV_AWS_109:Key policy - "*" is scoped to this key; root admin statement is the AWS default
  #checkov:skip=CKV_AWS_111:Key policy - "*" is scoped to this key; root admin statement is the AWS default
  #checkov:skip=CKV_AWS_356:Key policy - "*" is scoped to this key, not to all resources
  statement {
    sid       = "EnableIAMUserPermissions"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }

  statement {
    sid       = "AllowCloudTrailToEncryptLogs"
    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.cloudtrail_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = [local.cloudtrail_arn]
    }
  }

  statement {
    sid       = "AllowCloudTrailToDescribeKey"
    actions   = ["kms:DescribeKey"]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.cloudtrail_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }
  }
}

resource "aws_kms_key" "logs" {
  description             = "KMS key for encrypting security logs"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.logs_kms.json

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

# Bucket policy: CloudTrail may check the bucket ACL and write under this
# account's AWSLogs/ prefix, only on behalf of this trail. All non-TLS access
# is denied.
data "aws_iam_policy_document" "security_logs" {
  statement {
    sid       = "AWSCloudTrailAclCheck"
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.security_logs.arn]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.cloudtrail_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }
  }

  statement {
    sid       = "AWSCloudTrailWrite"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.security_logs.arn}/AWSLogs/${local.account_id}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.cloudtrail_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }
  }

  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.security_logs.arn,
      "${aws_s3_bucket.security_logs.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "security_logs" {
  bucket = aws_s3_bucket.security_logs.id
  policy = data.aws_iam_policy_document.security_logs.json

  # Apply the public access block first so the two calls don't race.
  depends_on = [aws_s3_bucket_public_access_block.security_logs]
}

resource "aws_cloudtrail" "main" {
  name                          = local.cloudtrail_name
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

  # CloudTrail checks bucket and key permissions when the trail is created.
  depends_on = [aws_s3_bucket_policy.security_logs]
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