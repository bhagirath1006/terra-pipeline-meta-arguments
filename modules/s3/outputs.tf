output "bucket_names" {
  description = "S3 bucket names"
  value = {
    for key, bucket in aws_s3_bucket.bucket : key => bucket.id
  }
}

output "bucket_arns" {
  description = "S3 bucket ARNs"
  value = {
    for key, bucket in aws_s3_bucket.bucket : key => bucket.arn
  }
}

output "bucket_regions" {
  description = "S3 bucket regions"
  value = {
    for key, bucket in aws_s3_bucket.bucket : key => bucket.region
  }
}

output "bucket_name" {
  description = "First bucket name"
  value       = try(values(aws_s3_bucket.bucket)[0].id, "")
}
