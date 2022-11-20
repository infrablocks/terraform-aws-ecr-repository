module "ecr_repository" {
  source = "../../../.."

  region = var.region

  repository_name = var.repository_name

  allow_in_account_lambda_access               = var.allow_in_account_lambda_access
  allow_cross_account_lambda_access            = var.allow_cross_account_lambda_access
  allowed_cross_account_lambda_access_accounts = var.allowed_cross_account_lambda_access_accounts
}
