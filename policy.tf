data "aws_iam_policy_document" "allow_in_account_lambda_access_statement" {
  statement {
    sid = "LambdaECRImageRetrievalPolicy"

    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
  }
}

data "aws_iam_policy_document" "allow_cross_account_lambda_access_statement" {
  statement {
    sid = "CrossAccountPermission"

    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        for account_id in local.allowed_cross_account_lambda_access_accounts:
          "arn:aws:iam::${account_id}:root"
      ]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
  }

  statement {
    sid = "LambdaECRImageCrossAccountRetrievalPolicy"

    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]

    condition {
      test     = "StringLike"
      values   = [
        for account_id in local.allowed_cross_account_lambda_access_accounts:
          "arn:aws:lambda:${var.region}:${account_id}:function:*"
      ]
      variable = "aws:sourceARN"
    }
  }
}

data "aws_iam_policy_document" "repository_policy_document" {
  source_policy_documents = [
    local.allow_in_account_lambda_access
    ? data.aws_iam_policy_document.allow_in_account_lambda_access_statement.json
    : "",
    local.allow_cross_account_lambda_access
    ? data.aws_iam_policy_document.allow_cross_account_lambda_access_statement.json
    : "",
  ]
}

resource "aws_ecr_repository_policy" "service" {
  count = (local.allow_in_account_lambda_access || local.allow_cross_account_lambda_access) ? 1 : 0

  repository = aws_ecr_repository.repository.name

  policy = data.aws_iam_policy_document.repository_policy_document.json
}
