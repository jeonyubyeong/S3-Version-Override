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
        Sid    = "IAMReadAccess",
        Effect = "Allow",
        Action = [
          "iam:ListUsers",
          "iam:ListUserPolicies",
          "iam:GetUserPolicy"
        ],
        Resource = "*"
      },
      {
        Sid    = "S3ReadOnly",
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
        Sid    = "DenyPutObjectOnBypassBucket",
        Effect = "Deny",
        Action = "s3:PutObject"
        Resource = "arn:aws:s3:::cg-s3-version-bypass-*/*"
    	},
      {
        Sid    = "CloudFormationLimited",
        Effect = "Allow",
        Action = [
          "cloudformation:CreateStack",
          "cloudformation:DescribeStacks",
          "cloudformation:GetTemplate"
        ],
        Resource = "*"
      },
      {
        Sid    = "AssumeAndPassOnlyExploitRole",
        Effect = "Allow",
        Action = [
          "sts:AssumeRole",
          "iam:PassRole",
          "iam:GetRole",
          "iam:CreateRole",
          "iam:TagRole",
          "iam:PutRolePolicy"
        ],
        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/CloudFormationRole"
      }
    ]
  })
}
