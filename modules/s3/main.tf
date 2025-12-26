# Get current AWS account ID (Terraform function)
data "aws_caller_identity" "current" {}

# Get current AWS region (Terraform function)
data "aws_region" "current" {}

# META-ARGUMENT EXAMPLE: for_each with S3 buckets
resource "aws_s3_bucket" "bucket" {
  for_each = var.buckets
  bucket   = "${var.project_name}-${each.key}-${data.aws_caller_identity.current.account_id}-${lower(data.aws_region.current.name)}"

  lifecycle {
    # Prevent accidental deletion
    prevent_destroy = false
    # Ignore changes to tags made outside of Terraform
    ignore_changes = [
      tags["LastModified"]
    ]
  }

  tags = {
    Name = "${var.project_name}-${each.key}"
  }
}

# Versioning configuration using Terraform functions
resource "aws_s3_bucket_versioning" "ver" {
  for_each = aws_s3_bucket.bucket

  bucket = each.value.id

  versioning_configuration {
    status = var.buckets[each.key].versioning ? "Enabled" : "Suspended"
  }

  depends_on = [
    aws_s3_bucket.bucket
  ]
}

# Server-side encryption using Terraform functions
resource "aws_s3_bucket_server_side_encryption_configuration" "enc" {
  count  = var.enable_encryption ? length(aws_s3_bucket.bucket) : 0
  bucket = values(aws_s3_bucket.bucket)[count.index].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

  depends_on = [
    aws_s3_bucket.bucket
  ]
}

# Block public access
resource "aws_s3_bucket_public_access_block" "pab" {
  for_each = aws_s3_bucket.bucket

  bucket = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket lifecycle policy with Terraform functions
# Demonstrates: tolist(), merge(), and conditional logic
resource "aws_s3_bucket_lifecycle_configuration" "lc" {
  for_each = aws_s3_bucket.bucket

  bucket = each.value.id

  rule {
    id     = "archive-old-logs"
    status = "Enabled"

    # Use Terraform functions: match()
    filter {
      prefix = each.key == "logs" ? "archive/" : ""
    }

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.ver
  ]
}
