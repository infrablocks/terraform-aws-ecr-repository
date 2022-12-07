locals {
  allowed_cross_account_lambda_pull_access_account_arns = [
    for account_id in var.allowed_cross_account_lambda_pull_access_account_ids :
      "arn:aws:iam::${account_id}:root"
  ]
}

data "aws_iam_policy_document" "allow_in_account_lambda_pull_access_statement" {
  statement {
    sid = "InAccountLambdaPullPermission"

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:DescribeImages"
    ]
  }
}

data "aws_iam_policy_document" "allow_aws_principal_pull_access_statement" {
  statement {
    sid = "AWSPrincipalPullPermission"

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = concat(
        var.allow_cross_account_lambda_pull_access ? local.allowed_cross_account_lambda_pull_access_account_arns : [],
        var.allow_role_based_pull_access ? var.allowed_role_based_pull_access_role_arns : []
      )
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:DescribeImages"
    ]
  }
}

data "aws_iam_policy_document" "allow_cross_account_lambda_pull_access_statement" {
  statement {
    sid = "CrossAccountLambdaPullPermission"

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:DescribeImages"
    ]

    condition {
      test   = "StringLike"
      values = [
      for account_id in var.allowed_cross_account_lambda_pull_access_account_ids :
      "arn:aws:lambda:${var.region}:${account_id}:function:*"
      ]
      variable = "aws:sourceARN"
    }
  }
}

data "aws_iam_policy_document" "repository_policy_document" {
  source_policy_documents = [
    var.allow_in_account_lambda_pull_access
    ? data.aws_iam_policy_document.allow_in_account_lambda_pull_access_statement.json
    : "",
    (var.allow_cross_account_lambda_pull_access || var.allow_role_based_pull_access)
    ? data.aws_iam_policy_document.allow_aws_principal_pull_access_statement.json
    : "",
    var.allow_cross_account_lambda_pull_access
    ? data.aws_iam_policy_document.allow_cross_account_lambda_pull_access_statement.json
    : "",
  ]
}

resource "aws_ecr_repository_policy" "service" {
  count = (var.allow_in_account_lambda_pull_access ||
           var.allow_cross_account_lambda_pull_access ||
           var.allow_role_based_pull_access) ? 1 : 0

  repository = aws_ecr_repository.repository.name

  policy = data.aws_iam_policy_document.repository_policy_document.json
}
