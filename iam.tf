resource "aws_iam_user" "web_manager" {
  name = "web_manager-${var.cgid}"
}

resource "aws_iam_access_key" "web_manager_key" {
  user = aws_iam_user.web_manager.name
}

resource "aws_iam_user_policy" "web_manager_policy" {
  name = "WebManagerRecoveryPolicy-${var.cgid}"
  user = aws_iam_user.web_manager.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "S3ReadAndVersioningAccess",
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucketVersions",
          "s3:GetObjectRetention"
        ],
        Resource = "*"
      },
      {
        Sid    = "CloudFormationAndIAMAccess",
        Effect = "Allow",
        Action = [
          "cloudformation:CreateStack",
          "iam:CreateRole",
          "iam:PutRolePolicy",
          "iam:PassRole",
          "sts:AssumeRole"
        ],
        Resource = "*"
      }
    ]
  })
}
