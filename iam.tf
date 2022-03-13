data "aws_iam_policy_document" "s3write-document" {
  statement {
    sid = "1"

    actions = [
      "s3:PutObject",
      "s3:CreateBucket",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }
}

resource "aws_iam_policy" "s3write" {
  name        = "GitHub-Actions-S3-policy"
  description = "Policy that allows PutObject and CreateBucket in S3"
  policy      = data.aws_iam_policy_document.s3write-document.json
}

data "aws_iam_policy" "cloudfrontfull" {
  arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"
}

data "aws_iam_policy_document" "webid_assume_role_policy_document" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo_path}:pull_request"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    effect = "Allow"

  }

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo_path}:ref:refs/heads/main"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    effect = "Allow"

  }
}

resource "aws_iam_role" "GitHubActions" {
  name               = "github-actions"
  assume_role_policy = data.aws_iam_policy_document.webid_assume_role_policy_document.json
}

resource "aws_iam_role_policy_attachment" "s3-attach" {
  role       = aws_iam_role.GitHubActions.name
  policy_arn = aws_iam_policy.s3write.arn
}

resource "aws_iam_role_policy_attachment" "cloudfront-attach" {
  role       = aws_iam_role.GitHubActions.name
  policy_arn = data.aws_iam_policy.cloudfrontfull.arn
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  tags = {
    environment = var.environment
    application = "GithubActions"
    purpose     = "CI-CD"
  }

  /*
    openssl s_client \
      -servername token.actions.githubusercontent.com \
      -showcerts -connect token.actions.githubusercontent.com:443 \
      < /dev/null 2>/dev/null | \
        openssl x509 -fingerprint -noout -in /dev/stdin | \
          sed 's/^\(SHA1\sFingerprint=\)\(.*\)/\2/;s/://g'
  */

  thumbprint_list = ["15E29108718111E59B3DAD31954647E3C344A231"]
}
