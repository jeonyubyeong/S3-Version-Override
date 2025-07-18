resource "aws_cloudfront_origin_access_control" "flag_oac" {
  name                              = "FlagOAC"
  description                       = "OAC for Flag Bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "flag_distribution" {
  enabled             = true
  default_root_object = "flag.txt"

  origin {
    domain_name = "${aws_s3_bucket.flag_bucket.bucket_regional_domain_name}"
    origin_id   = "FlagOrigin"

    origin_access_control_id = aws_cloudfront_origin_access_control.flag_oac.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "FlagOrigin"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
