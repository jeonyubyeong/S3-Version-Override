resource "aws_s3_bucket" "versioned_bucket" {
  bucket = "cg-s3-version-bypass-${var.cgid}"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Scenario = "s3-version-override"
  }
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.versioned_bucket.bucket

  index_document {
    suffix = "index.html"
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
        Effect = "Allow",
        Principal = "*",
        Action = [
          "s3:GetObject"
        ],
        Resource = "${aws_s3_bucket.versioned_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_object" "index_admin" {
  bucket       = aws_s3_bucket.versioned_bucket.id
  key          = "index.html"
  content      = "<h1>${var.flag_value}</h1>"
  content_type = "text/html"

  # Lifecycle ensures it's uploaded *first* (older version)
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_s3_bucket_object" "index_normal" {
  bucket       = aws_s3_bucket.versioned_bucket.id
  key          = "index.html"
  content      = "<h1>Welcome to our site</h1>"
  content_type = "text/html"

  depends_on = [
    aws_s3_bucket_object.index_admin
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_s3_object_lock_configuration" "lock_config" {
  bucket = aws_s3_bucket.versioned_bucket.id

  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = 1
    }
  }

  depends_on = [
    aws_s3_bucket.versioned_bucket
  ]
}
