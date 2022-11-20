locals {
  # default for cases when `null` value provided, meaning "use default"
  allow_in_account_lambda_access               = var.allow_in_account_lambda_access == null ? false : var.allow_in_account_lambda_access
  allow_cross_account_lambda_access            = var.allow_cross_account_lambda_access == null ? false : var.allow_cross_account_lambda_access
  allowed_cross_account_lambda_access_accounts = var.allowed_cross_account_lambda_access_accounts == null ? [] : var.allowed_cross_account_lambda_access_accounts
}
