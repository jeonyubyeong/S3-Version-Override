output "website_url" {
  value       = "http://${aws_s3_bucket.versioned_bucket.bucket}.s3-website-${data.aws_region.current.id}.amazonaws.com"
  description = "URL of the static website"
}
