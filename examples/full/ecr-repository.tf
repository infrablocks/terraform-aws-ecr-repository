module "ecr_repository" {
  source = "../../"

  region = var.region

  component = var.component

  repository_name = var.repository_name

  allow_in_account_lambda_pull_access = true
  allow_cross_account_lambda_pull_access = true
  allowed_cross_account_lambda_pull_access_account_ids = var.allowed_lambda_account_ids

  allow_role_based_pull_access = true
  allowed_role_based_pull_access_role_arns = [
    aws_iam_role.role1.arn,
    aws_iam_role.role2.arn
  ]
}
