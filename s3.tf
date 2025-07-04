resource "aws_s3_bucket" "versioned_bucket" {
  bucket              = "cg-s3-version-bypass-${var.cgid}"
  object_lock_enabled = true

  tags = {
    Scenario = var.scenario_name
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.versioned_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.versioned_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.versioned_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = ["s3:GetObject"],
        Resource  = "${aws_s3_bucket.versioned_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.versioned_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.versioned_bucket.id

  versioning_configuration {
    status     = "Enabled"
    mfa_delete = "Disabled"
  }

  depends_on = [aws_s3_bucket.versioned_bucket]
}

# 관리자용 index.html (먼저 업로드됨 → 이전 버전)
resource "aws_s3_object" "index_admin" {
  bucket       = aws_s3_bucket.versioned_bucket.id
  key          = "index.html"
  content      = "<h1>${var.flag_value}</h1>"
  content_type = "text/html"

  depends_on = [aws_s3_bucket_versioning.versioning]
}

# 정상 페이지 index.html (마지막 업로드 → 최신 버전 + Lock 적용)
resource "aws_s3_object" "index_normal" {
  bucket       = aws_s3_bucket.versioned_bucket.id
  key          = "index.html"
  content      = "<h1>Welcome to our site</h1>"
  content_type = "text/html"

  object_lock_mode               = "GOVERNANCE"
  object_lock_retain_until_date = "2099-12-31T00:00:00Z"

  depends_on = [
    aws_s3_object.index_admin,
    aws_s3_bucket_versioning.versioning
  ]
}
