resource "aws_s3_bucket" "index_bucket" {
  bucket = "cg-s3-version-index-${var.cgid}"
  tags = {
    Purpose = "Public Index"
  }
}

resource "aws_s3_bucket_website_configuration" "index_website" {
  bucket = aws_s3_bucket.index_bucket.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.index_bucket.id
  key          = "index.html"
  content_type = "text/html"  
  content      = <<EOT
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>S3 Flag Viewer</title></head>
<body style="background:#111;color:#0f0;text-align:center;padding-top:100px;font-family:monospace">
  <h1>🔓 S3 Flag Viewer</h1>
  <div id="flag">Loading flag...</div>
  <script>
    fetch("https://${aws_s3_bucket.flag_bucket.bucket}.s3.amazonaws.com/flag.txt")
    .then(r => r.text()).then(t => {
      document.getElementById("flag").innerHTML = "✅ FLAG: " + t;
    }).catch(e => {
      document.getElementById("flag").innerHTML = "❌ Failed to load flag";
    });
  </script>
</body>
</html>
EOT
}

resource "aws_s3_bucket" "flag_bucket" {
  bucket = "cg-s3-version-flag-${var.cgid}"
  tags = {
    Purpose = "Flag Only"
  }
}

resource "aws_s3_object" "flag_txt" {
  bucket       = aws_s3_bucket.flag_bucket.id
  key          = "flag.txt"
  content      = "Flag{secure_fetch_only}"
  content_type = "text/plain"
}

resource "aws_s3_bucket_policy" "flag_bucket_policy" {
  bucket = aws_s3_bucket.flag_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid: "AllowOnlyFromReferer",
        Effect: "Allow",
        Principal: "*",
        Action: "s3:GetObject",
        Resource: "${aws_s3_bucket.flag_bucket.arn}/flag.txt",
        Condition: {
          StringLike: {
            "aws:Referer": "http://${aws_s3_bucket.index_bucket.bucket}.s3-website.${var.region}.amazonaws.com/*"
          }
        }
      },
      {
        Sid: "DenyWithoutReferer",
        Effect: "Deny",
        Principal: "*",
        Action: "s3:GetObject",
        Resource: "${aws_s3_bucket.flag_bucket.arn}/flag.txt",
        Condition: {
          Null: {
            "aws:Referer": "true"
          }
        }
      },
      {
        Sid: "DenyFromIAMUsers",
        Effect: "Deny",
        Principal: "*",
        Action: "s3:GetObject",
        Resource: "${aws_s3_bucket.flag_bucket.arn}/flag.txt",
        Condition: {
          StringLike: {
            "aws:PrincipalArn": "arn:aws:iam::*:user/*"
          }
        }
      },
      {
        Sid: "DenyFromAssumedRoles",
        Effect: "Deny",
        Principal: "*",
        Action: "s3:GetObject",
        Resource: "${aws_s3_bucket.flag_bucket.arn}/flag.txt",
        Condition: {
          StringEquals: {
            "aws:PrincipalType": "AssumedRole"
          }
        }
      },
      {
        Sid: "DenyFromAuthenticatedUsers",
        Effect: "Deny",
        Principal: {
          AWS: "*"
        },
        Action: "s3:GetObject",
        Resource: "${aws_s3_bucket.flag_bucket.arn}/flag.txt",
        Condition: {
          Bool: {
            "aws:PrincipalIsAWSService": "false"
          },
          StringNotEquals: {
            "aws:userid": "anonymous"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_cors_configuration" "flag_cors" {
  bucket = aws_s3_bucket.flag_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["http://${aws_s3_bucket.index_bucket.bucket}.s3-website-${var.region}.amazonaws.com"]
    max_age_seconds = 3000
  }
}